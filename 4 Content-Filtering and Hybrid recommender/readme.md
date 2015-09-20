#Content-Based Filtering & Hybrid Recommender

1. [Get Data](#get)
2. [Clean Data](#clean)
3. [Build and Score Content-Based Filtering Model](#build)
4. [Publish Content-Based Filtering Model as a Web Service](#content-ws)
5. [Make it Hybrid](#hybrid)
   1. [User Features](#user)
   2. [Item Features](#items)
   3. [Build and Score the Hybrid Recommender Model](#buildhybrid)
6. [Publish the Hybrid Recommender as a Web Service](#ws)

[Back to top](#top)
<a name="get"></a>
##1. Get Data

We start off with reading data again from the Azure SQL Database containing the AdventureWorks Warehouse. Running the script [matchbox.sql](https://github.com/oliviak/Recommender-in-Azure/blob/master/4%20Content-Filtering%20and%20Hybrid%20recommender/matchbox.sql) in SQL Server Management Studio displays a dataset of five columns. The most important column is the last one: **FreqBuy**. Technically speaking, we want to have a ratings column, but since we do not have explicit ratings data, we infer the ratings implicitly from data collected. Here we assume that the more often you buy one item, the higher the rating a customer would give. Obviously, this assumption is not flawless since it may very well be possible that one buys an item multiple times since it wears off very quickly.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20data%202.png)

Create a new experiment in Machine Learning Studio called **Content-Based Filtering**. Expand **Data Input and Output** in the catalogue pane (in the left hand side) and drag the module **Reader** into the canvas. Configure it in the properties pane (on the right hand side) with the credentials of your Azure SQL Database containing the AdventureWorks database and paste in the query [matchbox.sql](https://github.com/oliviak/Recommender-in-Azure/blob/master/4%20Content-Filtering%20and%20Hybrid%20recommender/matchbox.sql): 

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20data%204.png)

Run the experiment. After it experiment finishes running, click on the circle at the **Reader** module in the canvas and then on **Visualize** to see the imported dataset of five columns:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20train%202.png)

[Back to top](#top)
<a name="clean"></a>
##2. Clean Data

Expand **Data Transformation** and then **Manipulation** in the catalogue pane to drag the module **Metadata Editor** into the canvas. Drag an arrow from the **Reader** module into **Metadata Editor** as shown below, and then click on **Launch column selector** in the properties pane:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%201.png)

We want to force the last column **FreqBuy** to be of integer and rename it. Thus, in the column selector we only choose the column name **FreqBuy** and click on the check mark:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%202.png)

In the properties pane, set the **Data Type** to be **Integer** and change the column name to **Rating** as shown below:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%203.png)

Now drag the module **Project Columns** into the canvas and an arrow from **Metadata Editor** into **Project Columns**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%204.png)

We only want three columns, since the MatchBox recommender that we will be using for training a recommender only takes in a dataset of triples: (user, item, rating). Translating it into our case, we need a dataset of the following three columns: CustomerKey, Model and Rating. Thus click on **Launch column selector** in the properties pane to select the aforementioned three columns:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%205.png)

[Back to top](#top)
<a name="build"></a>
##3. Build and Score Content-Based Filtering Model

Let's move on to building and then testing a recommendation model.
Expand **Data Transformation** and then **Sample and Split** in the catalogue pane to drag the module **Split** into the canvas. Drag an arrow from **Project Columns** into **Split** as shown below. Change the **Splitting Mode** in the properties pane to **Recommender Split**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20clean%206.png)

We can now train a model. Expand **Machine Learning** and then **Train** to insert **Train Matchbox Recommender** into the canvas. Drag an arrow from the first output of **Split** into the first input of **Train Matchbox Recommender** as follows:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20train%205.png)

After training the matchbox recommender, let's apply it on the remaining dataset kept aside when splitting. Expand **Score** under **Machine Learning** in the catalogue to drag the module **Score Matchbox Recommender** into the canvas. The first input of **Score Matchbox Recommender** is the output of **Train Matchbox Recommender**, while the second input is the second output of **Split**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%202%20train%206.png)

Run the experiment!

[Back to top](#top)
<a name="content-ws"></a>
##4. Publish Content-Based Filtering Model as a Web Service

The recommender is trained and tested. Now on to creating a web service out of it. Start off with saving the trained model by clicking on the circle of **Train Matchbox Recommender** and then on **Save as Trained Model**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%202.png)

Save the trained model as "Content-Based Filtering" or a name of your choice:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%203.png)

Back to the experiment, you can save the experiment as a new experiment, e.g. "Content-Based Filtering - Web Service". Select the two modules **Split** and **Train Matchbox Recommender**...

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%204.png)

...and delete the two:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%205.png)

Drag the module **Content-Based Filtering** listed in the catalogue under **Trained Models** into the canvas and connect it to the first input of **Score Matchbox Recommender**. Similarly, connect **Project Columns** to the second input of **Score Matchbox Recommender**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%206.png)

Click on **Project Columns** to launch the column selector in the properties pane:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%207.png)

The input of the web service should only require the customer key and not the model the customer has bought and rated. Hence, delete **Model** and **Rating** in the column selector:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%208.png)

Click on the module **Score Matchbox Recommender** and change the **Recommender item selection** from **From Rated Itmes (for model evaluation)** to **From All Items** in the properties pane:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%209.png)

Now insert the modules **Web Service Input** and **Web Service Output** in the experiment. These modules can be found under the category **Web Service** in the catalogue. Connect the **Web Service Input** module to the second input of **Score Matchbox Recommender**, and the **Web Service Output** to the one output of the **Score...** module. Then run the experiment.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%2010.png)

Once finished running, click on the button **Deploy Web Service** in the bottom bar:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%2011.png)

And we are redirected to the usual web service page of the newly deployed web service:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%203%20ws%2012.png)

[Back to top](#top)
<a name="hybrid"></a>
##5. Make it Hybrid

We now want to extend the content-/rating-based filtering approach to a hybrid recommender. This can be done by integrating user as well as item features - the remaining two inputs of the module **Train Matchbox Recommender**. User features encompass more information on the customers, such as demographic information, while item features contain information on the models, e.g. categories.

Recall that the **Reader** module imports a dataset of five columns; in other words, it contains demographic information on our customers but no further item features. What we will do in this section is on the one hand extract the user information and on the other hand create a "dummy" item feature set that will not change the outcome of the model, at all.

Let us first save the current experiment as another experiment:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%203.png)

Save it under the name **Hybrid Recommender**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%204.png)

And then run the experiment so that the column names of the imported dataset are in the cache. (It will make things easier later on when projecting certain columns.)

As mentioned earlier, the module **Train Matchbox Recommender** takes in three inputs, of which the first one is mandatory whereas the other two (2 and 3) are optional. The first input requires a triple-dataset, i.e. of the form (user, item, rating); the second input takes user features whereas the third one takes item features.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%205.png)

[Back to top](#top)
<a name="user"></a>
###5.a User Features

For sake of simplicity, we can delete the two modules **Train Matchbox Recommender** and **Score Matchbox Recommender** for now.
To obtain a set of user features, all we need to do is select the three columns related to the customer. Hence, take the module **Project Columns** (under **Data Transformation** and then under **Manipulation**) and connect it to **Metadata Editor**. Click on **Launch column selector**: 

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%206.png)

Select the three columns **CustomerKey**, **IncomeGroup** and **Region** and click on the check mark:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%207.png)

Insert the module **Remove Duplicate Rows** (also to be found under **Data Transformation**-->**Manipulation**) and connect it to **Project Columns**. The reason is that some customers bought multiiple items resulting in duplicate rows when only projecting the 3 user-relevant columns in the step before. Similar to the **Project Columns** module, click on **Launch column selector**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%208.png)

...and select the column name **customerkey**. This is the column indicating if a row is a duplicate or not.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%209.png)

[Back to top](#top)
<a name="items"></a>
###5.b Item Features

Now on to the item features which in this case will just be dummy data. We will create an item feature set of two columns: the **model** column and a column of only 1's, i.e.

| Model | Properties |
| :------- | :-----|
| Sport-100 | 1 |
| Water Bottle | 1 |
| Road Tire Tube | 1 |
| Patch Kit | 1 |

Since the **Properties** column contains the same value across all rows, it doesn't give any information gain and therefore will not make a difference on the recommender model.

There are two options: One is to use the model **Execute R Script** with the script [CreateItemFeatures.R](https://github.com/oliviak/Recommender-in-Azure/blob/master/4%20Content-Filtering%20and%20Hybrid%20recommender/CreateItemFeatures.R) followed by **Metadata Editor** to rename the columns and skip to the **[Remove Duplicate Rows](#skip)**.
![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2021.png)

Another option is just using the modules provided in AzureML to add the column of 1's for all rows. We start off with the column **Apply Math Operation** found under **Statistical Functions** in the catalogue. You connect it to **Metadata Editor**. In the properties pane you configure the following settings:

| Attribute | Value |
| :--- | :--- |
| Category | Compare |
| Comparison function | GreaterThan |
| Value to compare type | Constant |
| Constant value to compare | 0 |
| Selected columns | Column names: Rating |
| Output mode | Inplace |

Thus, click on **Launch column selector**...

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2011.png)

...and specify **column names** and select **Rating**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2012.png)

The properties of the module **Apply Math Operation** look as follows:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2013.png)

Insert the module **Metadata Editor** (under **Data Transformation** and then **Manipulation**) and connect it to **Apply Math Operation**. Select the column **Rating** (by clicking on **Launch column selector**), change the value under **Categorical** to **Make categorical** and set the new column name to **Properties** as shown below in the properties pane:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2014.png)

Use the module **Indicator Values** (also under **Data Transformation** and then **Manipulation**) to transform the column of TRUEs to 1's. Connect it to the **Metadata Editor** and select the column **Properties** in properties (i.e. launch the column selector). Run the experiment. 

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2015.png)

Drag **Project Columns** into the canvas, connect it to **Indicator Values** and select the columns **Model** and **Properties-1** (newly created by **Indicator Values**) by launching the column selector:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2016.png)

<a name="skip"></a>
Insert the module **Remove Duplicate Rows** (also under **Data Transformation**-->**Manipulation**), connect it to **Project Columns** and specify the column to **Model**, since obviously many items have been bought by multiple customers.

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2017.png)

[Back to top](#top)
<a name="buildhybrid"></a>
###5.c Build and Score the Hybrid Recommender Model

Train the matchbox recommender using all three inputs:

1. User-item-rating dataset, i.e. **CustomerKey**, **Model** and **Rating**
2. User features, i.e. **CustomerKey**, **IncomeGroup** and **Region**
3. Item features, i.e. **Model** and **Properties** (just a column of 1's)

Connect the inserted module **Train Matchbox Recommender** accordingly:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2018.png)

After training the model, it's time to apply it to test data. The inputs of the scoring module is as follows:

1. Trained matchbox recommender
2. Test dataset in the form of (user, item, rating), i.e. (**CustomerKey**, **Model**, **Rating**)
3. User features just like when training
4. Item features just like when training

Connect **Score Matchbox Recommender** as displayed below and run the experiment:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2019.png)

The experiment finished running:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%205%20hybrid%2020.png)


[Back to top](#top)
<a name="ws"></a>
##6. Publish the Hybrid Recommender as a Web Service

Save the trained model by clicking on the circle at **Train Matchbox Recommender** and then on **Save as Trained Model**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2001.png)

Save it as, say, Hybrid Recommender:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2002.png)

Optionally you can save the experiment under a different name, eg. **Hybrid Recommender - Web Service**. 
Delete the modules **Split** and **Train Matchbox Recommender** and instead insert the previously trained model **Hybrid Recommender** found under **Trained Models** in the catalogue. Connect the **Hybrid Recommender** module to the first input of **Score Matchbox Recommender**, and **Project Columns** of the mandatory dataset to the second input of the scoring module:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2004.png)

Click on **Project Columns** to only select the column **CustomerKey** since the input of our to-be-deployed web service should only require the customer key and no further information on bought items and ratings. Click on **Launch column selector** in the properties to remove the columns **Model** and **Rating**:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2005.png)

After that, click on the **Score Matchbox Recommender** module and change the **Recommended item selection** to **From All Items** in the properties pane (just like in [4. Publish Content-Based Filtering Model as a Web Service](#content-ws).

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2006.png)

Insert the **Input** and **Output** modules for our web service and connect them as follows:

- **Web Service Input** to the second input of **Score Matchbox Recommender**
- **Web Service Ouptut** to the one output of **Score Matchbox Recommender**

Then run the experiment!

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2007.png)

And once finished running publish it as a web service by clicking on the button **Deploy Web Service** in the bottom bar:

![](http://oliviak.blob.core.windows.net/blog/ML%20series/9%206%20hws%2008.png)

You have published your hybrid recommender model as a web service and now can integrate it in any app or dashboard etc.

[Back to top](#top)