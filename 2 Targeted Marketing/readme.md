#Targeted Marketing

Who doesn't know this situation: You get loads of newsletters that you sometimes *might* have a look at - but let's face it: most end up in trash or the spam folder. From the other point of view, that is the scenario every marketing person wants to avoid. As a marketing guru, you want to send out more personalised newsletters that will be read and ideally clicked on as well.

<iframe src="https://channel9.msdn.com/Series/Building-Recommendation-Systems-in-Azure/02--Targeted-Marketing-in-Azure-Machine-Learning/player" width="960" height="540" allowFullScreen frameBorder="0"></iframe>

In this scenario, we make use of the **AdventureWorks database**: We have a wide customer base for our bike shop and want to classify our customers as likely bike buyers or not, and thus run a more targeted marketing campaign.

In [this step-by-step guide](https://github.com/oliviak/Recommender-in-Azure/tree/master/0%20AdventureWorks%20in%20Azure%20SQL%20DB), I have gone through the steps on setting up the AdventureWorks Warehouse database in an Azure SQL Database. This is a prerequisite for running the following ML experiment.

0. [Prequisites](#prerequisites)
1. [Get Data](#getdata)
2. [Clean Data](#clean)
3. [Build Model](#build)
4. [Evaluate Model](#eval)
5. [Publish as Web Service](#publish)
6. [Use Web Service](#use)

[Back to top](#top)

<a name="prerequisites"></a>
###1. Prerequisites

- AdventureWorks Warehouse set up in an Azure SQL Database (see [here](https://github.com/oliviak/Recommender-in-Azure/tree/master/0%20AdventureWorks%20in%20Azure%20SQL%20DB) for a step-by-step guide)
- SQL Server Management Studio
- Excel
- Live ID, e.g. @outlook.com, @yahoo.com, etc.
- Azure subscription or [free trial](https://azure.microsoft.com/en-us/pricing/free-trial/) to set up the Azure SQL Database

<a name="getdata"></a>
###2. Get Data

![](https://oliviak.blob.core.windows.net/blog/ML%20series/6%203%20data%200.png)

The database of interest to us is **[dbo].[vTargetMail]** contained in the AdventureWorks database. Running `SELECT TOP 1000 * FROM [dbo].[vTargetMail]` gives us some information on vTargetMail:

![](https://oliviak.blob.core.windows.net/blog/ML%20series/6%203%20data%201.png)

We are particularly interested in the last column **BikeBuyer** indicating if a customer ended up **buying a bike or not** (hence binary classification).

Moving on to the ML Studio and having already created a new experiment, we now drag the Reader module into the canvas of ML studio to read in the data directly from the view **[dbo].[vTargetMail]** contained in the Azure SQL Database **AdventureWorksDW2014** (see [here](https://github.com/oliviak/Recommender-in-Azure/tree/master/0%20AdventureWorks%20in%20Azure%20SQL%20DB) for how to set it up).

![](https://oliviak.blob.core.windows.net/blog/ML%20series/6%203%20data%202.png)

On the right hand side (in the Properties pane) we specify the connection string as well as the credentials to read from the Azure SQL Database called AdventureWorksDW2014. In the database query we specify which columns are of interest to us when building the ML model, thus dropping columns, such as Title, FirstName etc.:

    SELECT [CustomerKey]
          ,[GeographyKey]
          ,[CustomerAlternateKey]
          ,[MaritalStatus]
          ,[Gender]
          ,cast ([YearlyIncome] as int) as SalaryYear
          ,[TotalChildren]
          ,[NumberChildrenAtHome]
          ,[EnglishEducation]
          ,[EnglishOccupation]
          ,[HouseOwnerFlag]
          ,[NumberCarsOwned]
          ,[CommuteDistance]
          ,[Region]
          ,[Age]
          ,[BikeBuyer]
      FROM AdventureWorksDW2014.[dbo].[vTargetMail]
  
[Back to Targeted Marketing Overview](#mkt)

<a name="clean"></a>
###3. Clean Data

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%204%20clean%200.png)

Now the part comes that usually is the most time consuming one: cleaning the data. It often takes up 80% of the time of the data scientists: figuring out what of your data is actually relevant. For the sake of focussing on merely building the ML model, cleaning the data here is kept very trivial: we simply drop some more columns within the ML studio, which is the use of the **Project Columns** module:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%204%20clean%201.png)

By clicking on **Launch column selector** in the Properties pane (on the right hand side), you can specify which columns you wish to drop or select (blacklist vs. whitelist). In this case, we only want to exclude two columns; thus, we start with all columns and exclude the particular two columns (that conveniently come up as a dropdown menu): CustomerAlternateKey and GeographyKey.
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%204%20clean%202.png)
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%204%20clean%203.png)

Note that there are plenty more modules for cleaning data within AzureML, all listed in the catalogue pane on the left hand side under **Data Transformation**.

[Back to Targeted Marketing Overview](#mkt)

<a name="build"></a>
###4. Build Model

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2000.png)

Once the data has been cleaned (although in this case admittedly a very trivial step), the model can be built based on the given data. Thinking a few steps ahead, how can we tell if a model is well performing or not? Hence, we **split the data in 80-20**: we use 80% to train a machine learning model but reserve the remaining 20% for testing the model:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2001.png)

Since we are dealing with a binary classification problem, the machine learning algorithms of interest to us are the "Two-Class ..." algorithms marked in red. Here, we choose the **Two-Class Boosted Decision Tree** (in green):
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2002.png)

Consider these algorithms as some empty templates that are useless without any data to be trained on. Hence, the module **Train Model** explicitly specifies which ML algorithm to use (1st input) and which data to train the algorithm on (2nd input):
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2003.png)

Notice the red exclamation mark in the "Train Model" module: We need to specify which column the model is supposed to "predict". Click on **Launch Column Selector** in the Properties pane:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2004.png)

Similar to the Column Selector in the Project Columns module, we can choose a column name from a dropdown menu. In our case, it is **BikeBuyer** (remember, we want to classify customers based on their demographic information if he/she is likely to buy a bike or not):
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2005.png)

Now that the model has been trained on specific data (i.e. [dbo].[vTargetMail]), we can test how well the model is doing on test data, i.e. the remaining 20% that we have put aside when splitting the data. For this purpose, you use the module called **Score Model** - another way of saying "Apply trained model on data...". 
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2006.png)

Now we come to one of the killer features of AzureML: You can easily compare different machine learning algorithms with each other. So we just **copy paste** the modules **Train Model** and **Score Model** within the ML studio: Select the modules "Train Model" and "Score Model"...

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2007.png)

...right-click on them to copy...
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2008.png)

...paste these two modules anywhere within the ML Studio...
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2009.png)

...and drag in another Two-Class classification algorithm: **Two-Class Bayes Point Machine**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2010.png)

Lines need to be dragged the same way as with training and scoring the boosted decision tree on the left hand side:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2011.png)

Finally, the module **Evaluate Model** allows one to quickly compare the two trained models using various evaluation metrics, such as the ROC-curve, the ration between precision and recall, and the lift-curve - more in the next section:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2012.png)

Run the experiment!
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%205%20build%2013.png)

[Back to Targeted Marketing Overview](#mkt)

<a name="eval"></a>
###5. Evaluate Model

You can see that the experiment has finished running in the top right corner and the green ticks in each module:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%206%20eval%201.png)

When clicking on the little circle in the **Evaluate Model** module, you can visualise the evaluation metrics of the two ML trained models as well as compare them with each other:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%206%20eval%202.png)

The metrics provided are the [ROC-curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic), the precision-recall diagram and the [lift curve](https://en.wikipedia.org/wiki/Receiver_operating_characteristic):
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%206%20eval%203.png)

The four values in the blue box represent the [confusion matrix](https://en.wikipedia.org/wiki/Confusion_matrix). It is a 2x2-matrix since it is a binary classification problem; it contains the absolute number of true positives (i.e. customer has been correctly predicted to be a bike buyer), true negatives (i.e. customer has been correctly predicted to be a no-buyer), false positives (i.e. customer has falsely been predicted to be a bike buyer) and false negatives. The values in the green box a typical evaluation measure: [accuracy](https://en.wikipedia.org/wiki/Accuracy_and_precision), [precision](https://en.wikipedia.org/wiki/Precision_and_recall#Precision), [recall](https://en.wikipedia.org/wiki/Precision_and_recall#Recall) and [F1](https://en.wikipedia.org/wiki/F1_score).

Just by looking at the ROC-curve (as well as looking at the other two diagrams), the first model outperforms the second one. Let's assume we have found our best performing machine learning model for our given problem.

Let's see what the better performing model has actually predicted. Click on the button of the left hand side **Score Model** and then click on **Visualize**: (Note you can also save the output as a  dataset)

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%206%20eval%204.png)

What the module *Score Model* has done is attach two more columns to the test dataset (i.e. the reserved 20% of the input dataset): **Scored Labels** and **Scored Probabilities**.
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%206%20eval%205.png)

The calculated probability indicates the the likelihood that a given customer is a bike buyer. For instance, the very first customer is predicted to be a bike buyer with a probability of 78%, whereas the third customer has a chance of being a bike buyer of merly 2,4% - making him a "no buyer". The threshold for the probability is set at 50% by default but can also be adjusted.

Comparing the columns **BikeBuyer** (so-called The Truth" and **Scored Labels** (the predictions), one can see how well a model has performed.

[Back to Targeted Marketing Overview](#mkt)

<a name="publish"></a>
###6. Publish as Web Service

![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2000.png)

Save the say best performing model by clicking on button at Train Model and click on **Save as Trained Model**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2004.png)

Give the trained model a name, e.g. Targeted Marketing Model:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2006.png)

Save the current experiment as a new experiment, since we are now undergoing preparations for a web service that will be called as we gather information about new customers who we want to classify as a likely buyer or not:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2001.png)
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2002.png)

In the web service experiment, there is no need for the "loser model" anymore - we will only require the model we have saved as a trained model. Thus, delete the modules in the canvas associated with the "loser model":
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2003.png)

Since we have saved the trained Two-Class Boosted Decision Tree, we can replace the two modules "Two-Class Boosted Decision Tree" and "Train Model" with the **trained model Targeted Marketing Model**. It is listed in the catalogue pane (on the left hand side) under **Trained Models**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2005.png)
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2007.png)

Here, we also delete the **Split** module since we are now only applying the trained module - no need to train and test it in the web service.

Let's take a step back: We want to have a web service that takes in all the demographic information that we can get on a new customer. What the web service is then supposed to give out is a prediction if we are dealing with a bike buyer or not. Hence, the **BikeBuyer** column needs to be excluded in the input of the web service. We accomplish this by clicking on the **Project Columns** module, launching the column selector and excluding the column **BikeBuyer**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2008.png)
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2009.png)

Now for the output of our web service, we only want to know the predictions along with the probabilities. Hence, add the module **Project Columns**...
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2010.png)

...and only include **Scored Labels** and **Scored Probabilities**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2011.png)
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2012.png)

The experiment is almost finished. Only things to specify are the input and output of the web service. Expand **Web Service** in the catalogue pane (on the left hand side) and drag in Input and Output as follows:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2013.png)

It is finished - time to run the experiment and then **deploy the web service**:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2014.png)

[Back to Targeted Marketing Overview](#mkt)


<a name="use"></a>
###7. Use Web Service

The result is a web service with its associated API key. We will go through the three (or rather four) options of using the web service: [1) Manual test](#test), [2) downloading the Excel workbook](#excel), and [3) request/response help page](#api).
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2015.png)


<a name="test"></a>
######7.1. Test
Test your web service by typing in the values for all criteria manually:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2016.png)

<a name="excel"></a>
######7.2. Excel workbook
The advantage of the Excel workbook is, you can simply copy paste multiple data rows from the AdventureWorks database (no need for manual typing). When opening the workbook, first enable the content:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2017.png)

Back in the SQL Server Management Studio with the AdventureWorks database connected, run the same query as when reading the data in ML studio. The only difference is: exclude the columns **[CustomerAlternateKey]**, **[GeographyKey]** and **[BikeBuyer]**. Also I selected the first 10 customers with a customer key higher than some random set number:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2018.png)

Here the script:

      SELECT Top 10 [CustomerKey]
            ,[MaritalStatus]
            ,[Gender]
            ,cast ([YearlyIncome] as int) as SalaryYear
            ,[TotalChildren]
            ,[NumberChildrenAtHome]
            ,[EnglishEducation]
            ,[EnglishOccupation]
            ,[HouseOwnerFlag]
            ,[NumberCarsOwned]
            ,[CommuteDistance]
            ,[Region]
            ,[Age]
            ,[BikeBuyer]
        FROM AdventureWorksDW2014.[dbo].[vTargetMail]
        WHERE CustomerKey > 11110

These are the first 10 customers then:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2019.png)

Copy all entries except for the last column (this is the column we aim to predict with the web service) into the Excel workbook. Give it a few minutes while the last two columns (**Predicted Values** in green) are being calculated by calling the web service:
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2020.png)

It turns out that our web service has incorrectly predicted bike buyers in two cases (marked in red). In fact, these have been identified as bike buyers with a probability of less than 90% - maybe the threshold for classifying a customer as a buyer needs to be raised from 50% to 90%?

<a name="api"></a>
######7.3. Request/Response API Documentation

And the final option (or more precisely the final two options) are documentation pages for request/response or batch execution manners. Hence, when you want to integrate your machine learning models in productive code, e.g. apps, dashboards, etc., these are the pages to refer to.
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2021.png)

When scrolling down to the very end, you will also get sample code in C#, Python and R, that you can just paste into your application code.
![](http://oliviak.blob.core.windows.net/blog/ML%20series/6%207%20ws%2022.png)

[Back to Targeted Marketing Overview](#mkt)

[Back to top](#top)