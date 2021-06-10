-----------------------------------------Dims + Facts--------------------------------------------------
-- DDL: FactInternetSales
DROP TABLE IF EXISTS [FinalProject].[dbo].[FactInternetSales]
CREATE TABLE [FinalProject].[dbo].[FactInternetSales](
	[SalesOrderID] [int] NOT NULL
	, [SalesOrderDetailID] [int] NOT NULL
	, [OrderDateKey] [date] NULL
	, [DueDateKey] [date] NULL
	, [ShipDateKey] [date] NULL
	, [SalesPersonKey] [int] NULL
	, [CustomerKey] [int] NULL
	, [ProductKey] [int] NULL
	, [Status] [nvarchar](5) NULL
	, [Freight] [decimal](15,4) NULL
	, [CarrierTrackingNumber] [nvarchar](25) NULL
	, [OrderQty] [int] NULL
	, [UnitPrice] [decimal](15,4) NULL
	, [UnitPriceDiscount] [decimal](15,4) NULL
	, [LineTotal] [decimal](15,4) NULL
	, [SubTotal] [decimal](15,4) NULL
	, PRIMARY KEY (SalesOrderID, SalesOrderDetailID)
) ON [PRIMARY]
SELECT * FROM [FinalProject].[dbo].[FactInternetSales]

-- DDL: DimCustomer
DROP TABLE IF EXISTS [FinalProject].[dbo].[DimCustomer]
CREATE TABLE [FinalProject].[dbo].[DimCustomer](
	CustomerKey [int] NOT NULL
	, AddressType [nvarchar](50) NOT NULL
	, BusinessEntityID [int] NULL
	, Title [nvarchar](10) NULL
	, FirstName [nvarchar](50) NULL
	, MiddleName [nvarchar](50) NULL
	, LastName [nvarchar](50) NULL
	, NameStyle [nvarchar](5) NULL
	, Suffix [nvarchar](10) NULL
	, EmailPromotion [nvarchar](5) NULL
	, EmailAddress [nvarchar](100) NULL
	, AddressLine1 [nvarchar](100) NULL
	, AddressLine2 [nvarchar](100) NULL
	, City [nvarchar](50) NULL
	, StateProvince [nvarchar](50) NULL
	, PostalCode [nvarchar](15) NULL
	, Phone [nvarchar](30) NULL
	, PhoneUpdateDate [datetime] NULL
	, PRIMARY KEY (CustomerKey, AddressType)
) ON [PRIMARY]

-- DDL: DimSalesPerson
DROP TABLE IF EXISTS [FinalProject].[dbo].[DimSalesPerson]
CREATE TABLE [FinalProject].[dbo].[DimSalesPerson](
	SalesPersonID [int] NOT NULL PRIMARY KEY,
	FirstName [nvarchar](50) NULL,
	MiddleName [nvarchar](50) NULL,
	LastName [nvarchar](50) NULL,
	Suffix [nvarchar](10) NULL,
	NationalIDNumber [nvarchar](15) NULL,
	LoginID [nvarchar](256) NULL,
	OrganizationNode [nvarchar](5) NULL,
	OrganizationLevel [nvarchar](5) NULL,
	BirthDate [date] NULL,
	MaritalStatus [nvarchar](5) NULL,
	Gender [nvarchar](5) NULL,
	HireDate [date] NULL,
	SalariedFlag [nvarchar](5) NULL,
	VacationHours [smallint] NULL,
	SickLeaveHours [smallint] NULL,
	CurrentFlag [nvarchar](5) NULL,
	SalesQuota [decimal](15,2) NULL,
	Bonus [decimal](15,2) NULL,
	CommissionPct [decimal](15,4) NULL,
	SalesYTD [decimal](15,4) NULL,
	SalesLastYear [decimal](15,4) NULL
) ON [PRIMARY]

-- DDL: DimProduct
DROP TABLE IF EXISTS [FinalProject].[dbo].[DimProduct]
CREATE TABLE [FinalProject].[dbo].[DimProduct](
	ProductKey [int] NOT NULL,
	HistoryCostID [int] NOT NULL,
	ProductName [nvarchar](50) NULL,
	ProductNumber [nvarchar](50) NULL,
	Color [nvarchar](15) NULL,
	Size [nvarchar](5) NULL,
	SizeUnitMeasureCode [nvarchar](5) NULL,
	Weight [decimal](8,2) NULL,
	WeightUnitMeasureCode [nvarchar](5) NULL,
	SafetyStockLevel [smallint] NULL,
	ReorderPoint [smallint] NULL,
	SellStartDate [date] NULL,
	SellEndDate [date] NULL,
	UnitCost [decimal](15,4) NULL,
	CostStartDate [date] NULL,
	CostEndDate [date] NULL,
	PRIMARY KEY (ProductKey, HistoryCostID)
) ON [PRIMARY]


-- DDL: FactInventory
DROP TABLE IF EXISTS [FinalProject].[dbo].[FactInventory]
CREATE TABLE [FinalProject].[dbo].[FactInventory](
	ProductKey [int] NOT NULL
	, DailyDate [date] NOT NULL
	, UnitCost [decimal](15,4) NULL
	, Unitin [smallint] NULL
	, UnitOut [smallint] NULL
	, PRIMARY KEY (ProductKey, DailyDate)
) ON [PRIMARY]


-- DDL: PreInv
DROP TABLE IF EXISTS [FinalProject].[dbo].[PreInv]
CREATE TABLE [FinalProject].[dbo].[PreInv](
	[ProductKey] [int] NULL,
	[DailyDate] [date] NULL,
	[UnitIn] [int] NULL,
	[UnitOut] [int] NULL
) ON [PRIMARY]
;


-- DDL: DimDate
DROP TABLE IF EXISTS [FinalProject].[dbo].[DimDate]
CREATE TABLE [FinalProject].[dbo].[DimDate](
	DailyDate [date] PRIMARY KEY NOT NULL
	, WeeklyDate [date] NOT NULL
	, MonthlyDate [date] NOT NULL
	, QuarterlyDate [date] NOT NULL
	, Year [int] NOT NULL
) ON [PRIMARY]


DECLARE @StartDate DATE = (SELECT MIN(SellStartDate) FROM Production.Product)		
, @EndDate DATE = (SELECT MAX(ModifiedDate) FROM Production.ProductInventory)		

INSERT INTO [FinalProject].[dbo].[DimDate]	
SELECT DailyDate		
	, CAST(DATEADD(week, DATEDIFF(week, 0, DailyDate), 0) AS DATE) AS WeeklyDate	
	, CAST(DATEADD(month, DATEDIFF(month, 0, DailyDate), 0) AS DATE) MonthlyDate	
	, CAST(DATEADD(quarter, DATEDIFF(quarter, 0, DailyDate), 0) AS DATE) AS QuarterlyDate	
	, YEAR(DailyDate) AS Year	
FROM (SELECT  DATEADD(DAY, nbr - 1, @StartDate) AS DailyDate		
	FROM    (SELECT ROW_NUMBER() OVER ( ORDER BY s.SalesOrderID ) AS Nbr	
			FROM  Sales.SalesOrderHeader s) nbrs		
	WHERE   Nbr - 1 <= DATEDIFF(DAY, @StartDate, @EndDate)	
) a

SELECT * FROM [FinalProject].[dbo].[DimDate] -- 20080430-20140812


----------------------------------------Staging Tables---------------------------------------------------------
DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_SalesOrderHeader];
CREATE TABLE [FinalProject].[dbo].[Staging_SalesOrderHeader](
	[SalesOrderID] [int] NOT NULL,
	[OrderDate] [date] NULL,
	[DueDate] [date] NULL,
	[ShipDate] [date] NULL,
	[Status] [nvarchar](5) NULL,
	[CustomerID] [int] NULL,
	[SalesPersonID] [int] NULL,
	[SubTotal] [decimal](15,4) NULL,
	[Freight] [decimal](15,4) NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_SalesOrderDetail];
CREATE TABLE [FinalProject].[dbo].[Staging_SalesOrderDetail](
	[SalesOrderID] [int] NULL,
	[SalesOrderDetailID] [int] NULL,
	[CarrierTrackingNumber] [nvarchar](25) NULL,
	[OrderQty] [int] NULL,
	[ProductID] [int] NULL,
	[UnitPrice] [decimal](15,4) NULL,
	[UnitPriceDiscount] [decimal](15,4) NULL,
	[LineTotal] [decimal](15,4) NULL
)ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_Employee];
CREATE TABLE [FinalProject].[dbo].[Staging_Employee](
	[BusinessEntityID] [int] NULL,
	[NationalIDNumber] [nvarchar](15) NULL,
	[LoginID] [nvarchar](256) NULL,
	[OrganizationNode] [nvarchar](5) NULL,
	[OrganizationLevel] [nvarchar](5) NULL,
	[BirthDate] [date] NULL,
	[MaritalStatus] [nchar](1) NULL,
	[Gender] [nchar](1) NULL,
	[HireDate] [date] NULL,
	[SalariedFlag] [nvarchar](5) NULL,
	[VacationHours] [smallint] NULL,
	[SickLeaveHours] [smallint] NULL,
	[CurrentFlag] [nvarchar](5) NULL,
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_Person];
CREATE TABLE [FinalProject].[dbo].[Staging_Person](
	[BusinessEntityID] [int] NOT NULL,
	[Title] [nvarchar](8) NULL,
	[FirstName] [nvarchar](50) NOT NULL,
	[MiddleName] [nvarchar](50) NULL,
	[LastName] [nvarchar](50) NOT NULL,
	[NameStyle] [nvarchar](5) NULL,
	[Suffix] [nvarchar](10) NULL,
	[EmailPromotion] [nvarchar](5) NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_SalesPerson];
CREATE TABLE [FinalProject].[dbo].[Staging_SalesPerson](
	[BusinessEntityID] [int] NOT NULL PRIMARY KEY,
	[SalesQuota] [decimal](15,2) NULL,
	[Bonus] [decimal](15,2) NULL,
	[CommissionPct] [decimal](15,4) NULL,
	[SalesYTD] [decimal](15,4) NULL,
	[SalesLastYear] [decimal](15,4) NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_Customer];
CREATE TABLE [FinalProject].[dbo].[Staging_Customer](
	[CustomerID] [int] NOT NULL,
	[PersonID] [int] NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_EmailAddress];
CREATE TABLE [FinalProject].[dbo].[Staging_EmailAddress](
	[BusinessEntityID] [int] NOT NULL,
	[EmailAddress] [nvarchar](50) NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_PersonPhone];
CREATE TABLE [FinalProject].[dbo].[Staging_PersonPhone](
	[BusinessEntityID] [int] NOT NULL,
	[PhoneNumber] [nvarchar](25) NOT NULL,
	[ModifiedDate] [datetime] NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_Address];
CREATE TABLE [FinalProject].[dbo].[Staging_Address](
	[AddressID] [int] NOT NULL,
	[AddressLine1] [nvarchar](60) NOT NULL,
	[AddressLine2] [nvarchar](60) NULL,
	[City] [nvarchar](30) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[PostalCode] [nvarchar](15) NOT NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_AddressType];
CREATE TABLE [FinalProject].[dbo].[Staging_AddressType](
	[AddressTypeID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_StateProvince];
CREATE TABLE [FinalProject].[dbo].[Staging_StateProvince](
	[StateProvinceID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_BusinessEntityAddress];
CREATE TABLE [FinalProject].[dbo].[Staging_BusinessEntityAddress](
	[BusinessEntityID] [int] NOT NULL,
	[AddressID] [int] NULL,
	[AddressTypeID] [int] NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_Product];
CREATE TABLE [FinalProject].[dbo].[Staging_Product](
	[ProductID] [int] NOT NULL,
	[Name] [nvarchar](50) NOT NULL,
	[ProductNumber] [nvarchar](25) NOT NULL,
	[Color] [nvarchar](15) NULL,
	[SafetyStockLevel] [smallint] NOT NULL,
	[ReorderPoint] [smallint] NOT NULL,
	[Size] [nvarchar](5) NULL,
	[SizeUnitMeasureCode] [nchar](3) NULL,
	[WeightUnitMeasureCode] [nchar](3) NULL,
	[Weight] [decimal](8, 2) NULL,
	[SellStartDate] [date] NOT NULL,
	[SellEndDate] [date] NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_ProductCostHistory];
CREATE TABLE [FinalProject].[dbo].[Staging_ProductCostHistory](
	[ProductID] [int] NOT NULL,
	[StartDate] [date] NOT NULL,
	[EndDate] [date] NULL,
	[StandardCost] [decimal](15,4) NOT NULL
) ON [PRIMARY]
;

DROP TABLE IF EXISTS [FinalProject].[dbo].[Staging_PurchaseOrderDetail];
CREATE TABLE [FinalProject].[dbo].[Staging_PurchaseOrderDetail](
	[ProductID] [int] NOT NULL,
	[OrderQty] [smallint] NULL,
	[DueDate] [datetime] NULL
) ON [PRIMARY]
;


SELECT * FROM [FinalProject].[dbo].[Staging_SalesOrderHeader]
SELECT * FROM [FinalProject].[dbo].[Staging_SalesOrderDetail]
SELECT * FROM [FinalProject].[dbo].[Staging_Employee]
SELECT * FROM [FinalProject].[dbo].[Staging_Person]
SELECT * FROM [FinalProject].[dbo].[Staging_SalesPerson]
SELECT * FROM [FinalProject].[dbo].[Staging_Customer]
SELECT * FROM [FinalProject].[dbo].[Staging_EmailAddress]
SELECT * FROM [FinalProject].[dbo].[Staging_PersonPhone]
SELECT * FROM [FinalProject].[dbo].[Staging_Address]
SELECT * FROM [FinalProject].[dbo].[Staging_AddressType]
SELECT * FROM [FinalProject].[dbo].[Staging_StateProvince]
SELECT * FROM [FinalProject].[dbo].[Staging_BusinessEntityAddress]
SELECT * FROM [FinalProject].[dbo].[Staging_Product]
SELECT * FROM [FinalProject].[dbo].[Staging_ProductCostHistory]
SELECT * FROM [FinalProject].[dbo].[Staging_PurchaseOrderDetail]
SELECT * FROM [FinalProject].[dbo].[PreInv] 

Truncate Table [FinalProject].[dbo].[Staging_SalesOrderHeader]
Truncate Table [FinalProject].[dbo].[Staging_SalesOrderDetail]
Truncate Table [FinalProject].[dbo].[Staging_Employee]
Truncate Table [FinalProject].[dbo].[Staging_Person]
Truncate Table [FinalProject].[dbo].[Staging_SalesPerson]
Truncate Table [FinalProject].[dbo].[Staging_Customer]
Truncate Table [FinalProject].[dbo].[Staging_EmailAddress]
Truncate Table [FinalProject].[dbo].[Staging_PersonPhone]
Truncate Table [FinalProject].[dbo].[Staging_Address]
Truncate Table [FinalProject].[dbo].[Staging_AddressType]
Truncate Table [FinalProject].[dbo].[Staging_StateProvince]
Truncate Table [FinalProject].[dbo].[Staging_BusinessEntityAddress]
Truncate Table [FinalProject].[dbo].[Staging_Product]
Truncate Table [FinalProject].[dbo].[Staging_ProductCostHistory]
Truncate Table [FinalProject].[dbo].[Staging_PurchaseOrderDetail]
TRUNCATE table [FinalProject].[dbo].[PreInv] 


SELECT * FROM [FinalProject].[dbo].[FactInternetSales]
SELECT * FROM [FinalProject].[dbo].[FactInventory]
SELECT * FROM [FinalProject].[dbo].[DimCustomer]
SELECT * FROM [FinalProject].[dbo].[DimSalesPerson]
SELECT * FROM [FinalProject].[dbo].[DimProduct]
SELECT * FROM [FinalProject].[dbo].[DimDate]


TRUNCATE table [FinalProject].[dbo].[FactInternetSales]
TRUNCATE table [FinalProject].[dbo].[FactInventory]
TRUNCATE table [FinalProject].[dbo].[DimCustomer]
TRUNCATE table [FinalProject].[dbo].[DimSalesPerson]
TRUNCATE table [FinalProject].[dbo].[DimProduct]
TRUNCATE table [FinalProject].[dbo].[DimDate]