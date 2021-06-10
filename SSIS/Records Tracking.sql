-- Initial
SELECT * FROM [FinalProject].[dbo].[FactInternetSales] 
-- 83,978 / 91,023 / 95,304 / 105,259 / 110,561 / 119,187 / 121,317 / 121,317
SELECT MAX(OrderDateKey) FROM [FinalProject].[dbo].[FactInternetSales] 
-- '2013-12-31' / '2014-01-31' / '2014-02-28' / '2014-03-31' / '2014-04-30' / '2014-05-31' / '2014-06-30' / '2014-06-30'

SELECT * FROM [FinalProject].[dbo].[FactInventory] 
-- 552,312 / 564,898 / 576,266 / 588,852 / 601,032 / 613,618 / 625,798 / 638,384 / 643,256
SELECT MAX(DailyDate) FROM [FinalProject].[dbo].[FactInventory] 
-- '2013-12-31' / '2014-01-31' / '2014-02-28'/ '2014-03-31' / '2014-04-30' / '2014-05-31' / '2014-06-30' / '2014-07-31' / '2014-08-12'

SELECT * FROM [FinalProject].[dbo].[DimCustomer] -- 13,114 / 19,844 / 19,844 / 19,844

SELECT * FROM [FinalProject].[dbo].[DimSalesPerson] -- 17 / 17
SELECT MAX(HireDate) FROM [FinalProject].[dbo].[DimSalesPerson] -- 2013-05-30


SELECT * FROM [FinalProject].[dbo].[DimProduct] -- 606 / 606
SELECT MAX(SellStartDate) FROM [FinalProject].[dbo].[DimProduct] -- 2013-05-30

SELECT * FROM [FinalProject].[dbo].[DimDate] -- 2,296




-- SCD
-- Customer phone
SELECT CustomerKey, BusinessEntityID, Phone, PhoneUpdateDate FROM [FinalProject].[dbo].[DimCustomer]
WHERE BusinessEntityID = 16722 OR BusinessEntityID = 16723
ORDER BY BusinessEntityID

SELECT * FROM [FinalProject].[dbo].[Staging_PersonPhone]
WHERE BusinessEntityID = 16722 OR BusinessEntityID = 16723

UPDATE [FinalProject].[dbo].[Staging_PersonPhone]
SET PhoneNumber = '99999', ModifiedDate = GETDATE()
WHERE BusinessEntityID = 16722 OR BusinessEntityID = 16723

-- UnitCost
SELECT ProductKey, HistoryCostID, ProductName, UnitCost, CostStartDate, CostEndDate 
FROM [FinalProject].[dbo].[DimProduct]
WHERE ProductKey = 707

SELECT * FROM [FinalProject].[dbo].[Staging_ProductCostHistory] 
WHERE ProductID = 707

UPDATE [FinalProject].[dbo].[Staging_ProductCostHistory] 
SET EndDate = '9999-01-01'
WHERE ProductID = 707 AND StartDate = '2013-05-30';

INSERT INTO [FinalProject].[dbo].Staging_ProductCostHistory 
VALUES ('707', '9999-01-01', Null, 99999)










