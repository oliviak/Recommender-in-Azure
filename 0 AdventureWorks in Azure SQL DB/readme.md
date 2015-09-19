#How to Set Up the Adventure Works 2014 Warehouse in Azure SQL Database

AdventureWorks is probably the most famous and openly available dataset any SQL-DBA can think of. For a machine learning experiment (in AzureML) I wanted to make use of that dataset - best to have it uploaded in an Azure SQL Database.

If you only want to use the AdventureWorks Lightweight database, this is easily done using the new [Azure portal](http://portal.azure.com) thanks to its integration:

![](https://oliviak.blob.core.windows.net/blog/data/01%2000%20adventureworks.png)
However, if you want to use other versions of the AdventureWorks dataset (like here in this case, i.e. AdventureWorks 2014 Warehouse), these are the steps to follow:

####1. Have SQL Server 2014 installed - either local or in a SQL Server VM in Azure
To spare my laptop from more and more programs, I decided to set up my SQL VM - a VM provided in the Azure portal that already has SQL Server 2014 Enterprise installed on Windows Server 2012 R2:

![](https://oliviak.blob.core.windows.net/blog/data/01%2001%20sql%20vm.png)

When creating my VM, I left the defaults as provided:

![](https://oliviak.blob.core.windows.net/blog/data/01%2002%20sql%20vm.png)

Once the VM is created, connect to it (for instance using the [Remote Desktop Connection Manager](http://www.microsoft.com/en-us/download/details.aspx?id=44989)):

![](https://oliviak.blob.core.windows.net/blog/data/01%2003%20sql%20vm.png)

When clicking on the start button, click on the arrow down to select the **SQL Server 2014 Management Studio** from the list of apps (since it is already convienently installed :) ): 

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20sql%20vm.png)


####2. Download Adventure Works 2014 Dataset
Download the zip-file **Adventure Works 2014 Warehouse Script.zip** from the AdventureWorks CodePlex site https://msftdbprodsamples.codeplex.com/releases/view/125550 and extract it.

![](https://oliviak.blob.core.windows.net/blog/data/01%2002%20adventureworks.png)

####3. Build Adventure Works 2014 Warehouse Locally
Open **instawdbdw.sql** in the extracted zip-file in SQL Server Management Studio.
Before you execute the SQL-file, change the directories accordingly:

- `SqlSamplesDatabasePath`: path where you want to build your databases
- `SqlSamplesSourceDataPath`: path of the extracted zip-file

![](https://oliviak.blob.core.windows.net/blog/data/01%2003%20local%201.png)

Activate **cmd**-mode (otherwise running the script will result in errors):

![](https://oliviak.blob.core.windows.net/blog/data/01%2003%20local%202.png)

And off you go - execute!

![](https://oliviak.blob.core.windows.net/blog/data/01%2003%20local%203.png)


####4. Deploy to Azure
Before you deploy the newly created database **AdventureWorksDW2014** to Azure, you first need to create an Azure SQL Database:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%203.png)

In the meantime, going back to SQL Server Management Studio, right click on the database **AdventureWorksDW2014**, then Tasks and then click on **Deploy Database to Windows Azure SQL Database...**:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%201.png)

This will guide you through a wizard:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%204.png)

Obviously, you need to specify which Azure SQL Database to deploy to; thus creating a SQL DB at the beginning of section 4. In this case, I created a SQL server in Azure called `oliviak-advworks.database.windows.net`:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%202.png)

Paste the server name into the pop-up windows and enter your credentials to connect to your newly create Azure SQL Server and then on **Next**:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%205.png)

Finally, as with every wizard, you are faced with a summary of the specified settings, which all looks fine:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%206.png)

The deployment may take a few minutes:

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%207.png)
![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%208.png)

And yes - in the Management Studio, you can see all tables and views uploaded in the SQL Azure Database AdventureWorksDW2014, including the view **dbo.vTargetMail** which I want to use in later ML experiments but which is not included in the lightweight version of AdventureWorks.

![](https://oliviak.blob.core.windows.net/blog/data/01%2004%20azure%209.png)