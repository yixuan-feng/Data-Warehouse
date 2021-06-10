# Data-Warehouse 
AdventureWorks 2019 is an OLTP sample database originally published by Microsoft, which stores the data of an ecommerce retail company from multiple perspectives, such as sales, production and relative people. However, it is difficult for analysts of the company to effectively get insights and create business values, because it costs much time to integrate information from multiple tables in a database. Thus, to enhance the data quality and consistency, improve the decision-making process, and generate a higher return of interest based on business intelligence, it is necessary for us to maintain a data warehouse for OLAP.

In this project, the goals include: 
● Build a data warehouse (dimensional model) of the AdventureWorks 2019 database - consolidate two fact tables FactInternetSales and FactProductInventory to present the data of internet sales and inventory in a clear manner
● Design and construct data pipeline via SSIS to automatically populate or backup data into our dimension and fact tables
● Feed data into an OLAP model for to improve efficiency of multi-dimensional analytical queries
● Integrate with BI tools to support underlying data reports refreshing and enable business intelligence
