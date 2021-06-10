USE AdventureWorks2019
GO

-- FactInternetSales
SELECT 
	soh.SalesOrderID
	, sod.SalesOrderDetailID
	, soh.OrderDate AS OrderDateKey
	, soh.DueDate AS DueDateKey
	, soh.ShipDate AS ShipDateKey
	, soh.SalesPersonID AS SalesPersonKey
	, soh.CustomerID AS CustomerKey
	, sod.ProductID AS ProductKey
	, soh.Status
	, soh.Freight
	, sod.CarrierTrackingNumber
	, sod.OrderQty
	, sod.UnitPrice
	, sod.UnitPriceDiscount
	, sod.LineTotal
	, soh.SubTotal
FROM Sales.SalesOrderHeader soh
INNER JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
ORDER BY soh.SalesOrderID

-- DimCustomer
SELECT 
	c.CustomerID AS CustomerKey
	, ISNULL(pat.Name, 'Default') AS AddressType
	, pp.BusinessEntityID
	, pp.Title
	, pp.FirstName
	, pp.MiddleName
	, pp.LastName
	, pp.NameStyle
	, pp.Suffix
	, pp.EmailPromotion
	, pe.EmailAddress
	, pa.AddressLine1
	, pa.AddressLine2
	, pa.City
	, ps.Name AS StateProvince
	, pa.PostalCode
	, pph.PhoneNumber AS Phone
	, pph.ModifiedDate
FROM Sales.Customer c
LEFT JOIN Person.Person pp ON c.PersonID = pp.BusinessEntityID
LEFT JOIN Person.EmailAddress pe ON pp.BusinessEntityID = pe.BusinessEntityID
LEFT JOIN (SELECT * FROM Person.PersonPhone WHERE ModifiedDate < '2014-01-01') pph ON pp.BusinessEntityID = pph.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress pbea ON pp.BusinessEntityID = pbea.BusinessEntityID
LEFT JOIN Person.Address pa ON pbea.AddressID = pa.AddressID
LEFT JOIN Person.AddressType pat ON pbea.AddressTypeID = pat.AddressTypeID
LEFT JOIN Person.StateProvince ps ON pa.StateProvinceID = ps.StateProvinceID


-- DimSalesperson
SELECT 
	SSP.BusinessEntityID AS SalesPersonID,
	PP.FirstName,
	PP.MiddleName,
	PP.LastName,
	PP.Suffix,
	HRE.NationalIDNumber,
	HRE.LoginID,
	HRE.OrganizationNode,
	HRE.OrganizationLevel,
	HRE.BirthDate,
	HRE.MaritalStatus,
	HRE.Gender,
	HRE.HireDate,
	HRE.SalariedFlag,
	HRE.VacationHours,
	HRE.SickLeaveHours,
	HRE.CurrentFlag,
	SSP.SalesQuota,
	SSP.Bonus,
	SSP.CommissionPct,
	SSP.SalesYTD,
	SSP.SalesLastYear
FROM Sales.SalesPerson SSP 
LEFT JOIN HumanResources.Employee HRE ON HRE.BusinessEntityID = SSP.BusinessEntityID
LEFT JOIN Person.Person PP ON HRE.BusinessEntityID = PP.BusinessEntityID

-- Initial load - DimProduct
SELECT					
	PP.ProductID AS ProductKey,
	ISNULL(PPCH.HistoryCostID, 1) AS HistoryCostID,
	PP.Name AS ProductName,
	PP.ProductNumber,
	PP.Color,
	PP.Size,
	PP.SizeUnitMeasureCode,
	PP.Weight,
	PP.WeightUnitMeasureCode,
	PP.SafetyStockLevel,
	PP.ReorderPoint,
	PP.SellStartDate,
	PP.SellEndDate,
	PPCH.UnitCost,
	PPCH.StartDate AS CostStartDate,
	PPCH.EndDate AS CostEndDate
FROM Production.Product PP
LEFT JOIN 
(SELECT 
	ProductID
	, ROW_NUMBER() OVER (Partition by ProductID Order by StartDate ASC) AS HistoryCostID
	, StartDate
	, EndDate
	, StandardCost AS UnitCost
FROM Production.ProductCostHistory) PPCH
	ON PP.ProductID = PPCH.ProductID

-- Inventory
WITH UnitIn AS (
SELECT ProductID, SUM(OrderQty) UnitIn, CAST(DueDate AS DATE) AS UnitInDate
FROM Purchasing.PurchaseOrderDetail
GROUP BY ProductID, DueDate
), -- 8,243 / 265

UnitOut AS (
SELECT ProductID, SUM(OrderQty) AS UnitOut, CAST(OrderDate AS DATE) AS UnitOutDate
FROM Sales.SalesOrderHeader soh
LEFT JOIN Sales.SalesOrderDetail sod
	ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY ProductID, OrderDate
), -- 26,878 / 266

ProdDate AS ( 
SELECT p.ProductKey, d.DailyDate
FROM (SELECT * FROM [FinalProject].[dbo].[DimProduct] WHERE HistoryCostID = 1) p -- Deduplicate
LEFT JOIN [FinalProject].[dbo].[DimDate] d
	ON d.DailyDate >= p.SellStartDate
	AND d.DailyDate <= ISNULL(p.SellEndDate, '2014-08-12') -- 2 cases: prod with / without SellEndDate
WHERE p.ProductKey IS NOT NULL
), --643,256 / 504

PreInv AS (
SELECT pd.ProductKey, pd.DailyDate, ISNULL(i.UnitIn, 0) AS UnitIn, ISNULL(o.UnitOut, 0) AS UnitOut
FROM ProdDate pd 
LEFT JOIN UnitIn i ON pd.ProductKey = i.ProductID AND pd.DailyDate = i.UnitInDate
LEFT JOIN UnitOut o ON pd.ProductKey = o.ProductID AND pd.DailyDate = o.UnitOutDate
), -- 643,256 / 504

Inventory AS (
SELECT inv.ProductKey, inv.DailyDate, inv.UnitIn, inv.UnitOut, c.UnitCost
FROM PreInv inv
LEFT JOIN [FinalProject].[dbo].[DimProduct] c
	ON inv.ProductKey = c.ProductKey AND inv.DailyDate BETWEEN c.CostStartDate AND ISNULL(c.CostEndDate, '2014-08-12')
) -- 643,256 

SELECT * FROM Inventory