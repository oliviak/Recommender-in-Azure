#Collaborative Filtering: Association Rules in R & AzureML

1. [[RStudio] Association Rules in R](#r)
2. [[RStudio] Think Ahead: Web Service Input and Output in Azure Machine Learning](#rout)
3. [[AzureML] Set Up Web Service Experiment](#aml)

Full R script is [Item-to-Item.R](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/Item-to-item.R).

###Prerequisites:
- [R](https://cran.rstudio.com/) 2.11.1 (or higher)
- [RStudio](https://www.rstudio.com/products/rstudio/download/)
- Live ID, e.g. @outlook.com, @yahoo.com, etc. OR Azure subscription OR Azure [free trial](https://azure.microsoft.com/en-us/pricing/free-trial/)

<a name="r"></a>
##1. [RStudio] Association Rules in R

###Terminology
| Term | Description          |
| :------------- | :----------- |
| **Item**      | Element or entity |
| **Itemset**     | Any subset containing the items  |
| **Transaction**  | Itemset associated with a unique transaction id     |
| **Rule**     | Implication in the form of X --> Y Where X and Y are itemsets and mutually exclusive  |
| **Support**     | The support of an itemset is the proportion of transactions in the database containing the given itemset |
| **Confidence**     | Measure of uncertainty or trust worthiness associated with each discovered pattern |

###1.a Read Data
Open RStudio and change your working directory to the one containing the required csv-files by going to the Files view in the bottom right and navigating to the directory:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%209.png)

Then read the data [ItemsBasket.csv](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/ItemsBasket.csv)

	ItemsBasket = read.csv("ItemsBasket.csv")

Once executed on the top right in the Environment view, you see some data **ItemsBasket** imported

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%2010.png)

Clicking on **ItemsBasket** displays on the left hand side what is contained in **ItemsBasket**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%201.png)

###1.b Import R packages

Install the packages [arules](https://cran.r-project.org/web/packages/arules/index.html) (R package for association rules and frequent itemsets) and [arulesViz](https://cran.r-project.org/web/packages/arulesViz/index.html) (R package for visualising association rules and frequent itemsets ) by opening the Packages view on the bottom right and checking the boxes next to arule and arulesViz:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%2011.png)

And import these libraries into our working directory by executing the following commands in the Souce view (in the top left):

	library( arules )
	library( arulesViz )

###1.c Transactions
Transaction := set of items (**itemset**), e.g. 
A **transaction** is a set of items. So we want to "summarise" all the items bought together into sets of items (i.e. transactions)

#####Read Transactions
The command for creating transactions from given csv file is as follows:

	tr = read.transactions("ItemsBasket.csv", format="basket", sep=",")

#####Summary of Transactions
To obtain some more information about the transactions from **ItemsBasket**, run the following command:

	summary(tr)

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%203.png)

Based on the summary, we know that one can buy 46 different items in our fictional bike shop and it contains 20,745 different itemsets. The most frequent items bought are Sport-100, water bottles etc.

#####Visualise Transactions
We can also visualise the items being bought using a histogram. This is where the library **arulesViz** is useful.

	itemFrequencyPlot(tr, topN=20, type="absolute")

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%204.png)

###1.d Apriori Rules
Based on the transactions, we now create the association rules (based on the Apriori algorithm):

	rules <- apriori(tr, parameter = list(supp = 0.001, conf = 0.8))
	
Here we are only interested in rules with a support of at least 0.001 and a confidence of at least 0.8.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%205.png)

We can see that 219 association rules have been deduced from the 20,745 transactions. Sorting the rules with decreasing confidence is then done using the following R command:

	rules <- sort(rules, by="confidence", decreasing=TRUE)

#####Inspect rules
Inspecting the association rules lets us have a closer look at the rules themselves:

	inspect(rules)

We obtain a list of 219 association rules all in the form of a left hand side (LHS aka X) and a right hand side (RHS aka Y) being the consequence of LHS. Associated with each rule are the metrics **support**, **confidence** and **lift**.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%206.png)

You notice that all rules have a confidence of at least 0.8 as specified when creating the association rules. Confidence indicates the probability of the RHS happening given that LHS has happened.

Wrapping up, we have created all the association rules of interest based on a dataset that contains all the items bought together by various customers. These association rules serve as a basis for giving recommendation to any new customer.

[Back to top](#top)

<a name="rout"></a>
##2. [RStudio] Think Ahead: Web Service Input and Output in Azure Machine Learning

We now want to make use of the created and sorted association rules when giving recommendations to a new customer. Thinking one step further, eventually we want to have a web service that takes the customer's bought items (or items currently in the cart) as input and gives out other recommended items as output. 

#####Web Service Input

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%207.png)

We first read some dummy input data, i.e. [R Bike Input.csv](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/R%20Bike%20Input.csv).

	dataset1 = read.csv("R Bike Input.csv")

dataset1 is a 1x2 matrix that we transform into a row-major vector:
	
    dataset1 <- as.vector(t(dataset1))

#####Find rules with given input as LHS (left hand side)

Given the items our new customer has bought or has currently placed in her/his cart, we now want to give further recommendations. Thus, we select all the association rules with the given items (i.e. `dataset1`) contained in their LHS's: 

	rulesMatchLHS <- subset(rules,lhs %ain% dataset1)

Note the use of `%ain%` specifying that the LHS of selected rules must contain all given items. If you use `%in%`, all rules with LHS containing any of the given items will be selected. To see which rules were selected, just run

	inspect(rulesMatchLHS)

#####Web Service Output
As an output for a web service, we first make do with a data frame containing the given items (i.e. LHS), recommended items (i.e. RHS) and their associated quality (i.e. support, confidence and lift):

    OutputClient =data.frame(  lhs = labels(lhs(rulesMatchLHS))$elements,
                               rhs = labels(rhs(rulesMatchLHS))$elements,
                               rulesMatchLHS@quality)

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%202%20r%208.png)

What **OutputClient** looks like as follows:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%204.png)

[Back to top](#top)

<a name="aml"></a>
##3. [Azure Machine Learning Studio] Set Up Web Service Experiment

Let us now integrate the R script into an experiment in Azure Machine Learning. Why? Once integrated, you can deploy this as a web service in integrate your machine learning model in no time in any app or dashboard and scale it through the cloud.

####3.a Import Datasets & Create New Experiment

First, you import both csv files, one as a zip-file ("Script Bundle") and the other as a csv-file.

Navigate to the Machine Learning Studio (http://studio.azureml.net/), and click on **New**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%205.png)

Click on **Dataset** and then on **From Local File**:
 
![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%206.png)

Upload a zip-file containing the [ItemsBasket.csv](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/ItemsBasket.csv) file:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%207.png)

Repeat the last three steps again to upload [R Bike Input.csv](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/R%20Bike%20Input.csv) as a csv-file:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%208.png)

Now that both datasets have been imported, create a new experiment called "Collaborative Filtering":

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%203%20aml%2010.png)


####3.b Set Up R Experiment  

Drag the two imported datasets from the step before by expanding **Saved Datasets** and then **My Datasets** in the catalogue pane on the left hand side into the canvas:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2001.png)

Expand **R Language Modules** in the catalogue pane to drag **Execute R Script** into the pane. Drag an arrow from **R-Bike-Input** into the first input of **Execute R Script**, and drag another arrow from **ItemsBasket.zip** into the third input of **Execute R Script** as shown below:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2002.png)

In the properties pane (on the right hand side), paste the R script from the 2 main steps before with slight changes (or just [R-Script-in-AzureML.R](https://github.com/oliviak/Recommender-in-Azure/blob/master/3%20Collaborative%20Filtering/R-Script-in-AzureML.R)) into the **R Script** field:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2003.png)

Run the experiment:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2005.png)

Once the experiment has finished running, we can have a look at the results of the R script by clicking on the first output of **Execute R Script** and then clicking on **Visualize**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2010.png)

We get the same result as back in RStudio of **OutputClient**: two association rules with their LHS's including the two items (Touring-3000 and Water Bottle) from R-Bike-Input alongside with their RHS and the metrics support, confidence and lift.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2011.png)

Now we can go ahead and specify the input and output of our upcoming web service. First, expand **Data Transformation** and then **Manipulation** in the catalogue pane to drag **Project Columns** into the canvas. The reason is to only obtain the RHS of the resulting association rules (i.e. further recommended items) as the output of our web service. Once **Project Columns** is inside the canvas, drag an arrow from the first output of **Execute R Script** into **Project Columns**.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2006.png)

To specify the columns **rhs** to be outputted, click on **Launch column selector** in the properties pane. In the dropdown menu, **rhs** is conveniently displayed and will be selected:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2007.png)

Then click on the check mark:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2008.png)

Now to finish the web service experiment, expand **Web Service** in the catalogue and drag in **Input** and **Output** as well as the arrows as shown below:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%204%20exp%2009.png)

Run the experiment!

####3.c Publish as Web Service

Once the experiment has finished running, you can deploy it as a web service by clicking the button on the bottom bar:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%205%20ws%201.png)

You will be automatically redirected to a web service page that contains the unique API key:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/8%205%20ws%202.png)

Similar to the experiment [**Targeted Marketing**](https://github.com/oliviak/Recommender-in-Azure/tree/master/2%20Targeted%20Marketing) there are three options of using the site:

1. API help pages with sample codes in R, Python or C# to integrate your model / web service into any production code. Here are two modes possible: request/response and batch execution. 
2. Testing the web service with one customer and his/her preferred items.
3. Downloading an Excel workbook that will call the web service to give recommendations for any given number of customers.

[Back to top](#top)