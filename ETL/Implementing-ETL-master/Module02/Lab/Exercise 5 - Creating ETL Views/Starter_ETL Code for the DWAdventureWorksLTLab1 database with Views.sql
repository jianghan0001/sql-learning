/*************************************************************
*                                                            *
*   Copyright (C) Microsoft Corporation. All rights reserved.*
*                                                            *
*************************************************************/


 --****************** [ DWAdventureWorksLT2012Lab1 ETL Code ] *********************--
-- This file will flush and fill the sales data mart in the DWAdventureWorksLT2012Lab1 database
--***********************************************************************************************--
Use DWAdventureWorksLT2012Lab01;
go

--********************************************************************--
-- Create ETL Views
--********************************************************************--
If (object_id('vETLDimCustomersData') is not null) Drop View vETLDimCustomersData;
go
CREATE VIEW vETLDimCustomersData
--< Add you ETL Select Satement here!  >-- 
go

If (object_id('vETLDimProductsData') is not null) Drop View vETLDimProductsData;
go
CREATE VIEW vETLDimProductsData
AS
--< Add you ETL Select Satement here!  >-- 
go

If (object_id('vETLFactSalesData') is not null) Drop View vETLFactSalesData;
go
CREATE VIEW vETLFactSalesData
AS
--< Add you ETL Select Satement here!  >-- 
go


 
--********************************************************************--
-- Drop Foreign Key Constraints
--********************************************************************--

ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesToDimProducts;

ALTER TABLE dbo.FactSales DROP CONSTRAINT 
	fkFactSalesToDimCustomers;

ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesOrderDateToDimDates;

ALTER TABLE dbo.FactSales DROP CONSTRAINT
	fkFactSalesShipDateDimDates;			

--********************************************************************--
-- Clear Table Data
--********************************************************************--

TRUNCATE TABLE dbo.FactSales;
TRUNCATE TABLE dbo.DimCustomers;
TRUNCATE TABLE dbo.DimProducts; 
  

--********************************************************************--
-- Fill Dimension Tables
--********************************************************************--

-- DimCustomers
INSERT INTO [DWAdventureWorksLT2012Lab01].[dbo].[DimCustomers]
( [CustomerID]
, [CompanyName]
, [ContactFullName]
)
SELECT 
	  [CustomerID]
	, [CompanyName]
	, [ContactFullName]
FROM  [DWAdventureWorksLT2012Lab01].[dbo].[vETLDimCustomersData]
go

-- DimProducts
INSERT INTO [DWAdventureWorksLT2012Lab01].[dbo].[DimProducts]
( [ProductID]
, [ProductName]
, [ProductColor]
, [ProductListPrice]
, [ProductSize]
, [ProductWeight]
, [ProductCategoryID]
, [ProductCategoryName]
)
SELECT 
	  [ProductID]
	, [ProductName]
	, [ProductColor]
	, [ProductListPrice]
	, [ProductSize]
	, [ProductWeight]
	, [ProductCategoryID]
	, [ProductCategoryName]
FROM  [DWAdventureWorksLT2012Lab01].[dbo].[vETLDimProductsData]
go

--********************************************************************--
-- Fill Fact Tables
--********************************************************************--

-- Fill Fact Sales 
INSERT INTO [DWAdventureWorksLT2012Lab01].[dbo].[FactSales]
( [SalesOrderID]
, [SalesOrderDetailID]
, [CustomerKey]
, [ProductKey]
, [OrderDateKey]
, [ShipDateKey]
, [OrderQty]
, [UnitPrice]
, [UnitPriceDiscount]
)
SELECT 
	  [SalesOrderID]  
	, [SalesOrderDetailID] 
	, [CustomerKey]
	, [ProductKey]
	, [OrderDateKey]
	, [ShippedDateKey]
	, [OrderQty]
	, [UnitPrice]
	, [UnitPriceDiscount]
FROM [DWAdventureWorksLT2012Lab01].[dbo].[vETLFactSalesData] 
go

--********************************************************************--
-- Replace Foreign Key Constraints
--********************************************************************--
ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesToDimProducts FOREIGN KEY (ProductKey) 
	REFERENCES dbo.DimProducts	(ProductKey);

ALTER TABLE dbo.FactSales ADD CONSTRAINT 
	fkFactSalesToDimCustomers FOREIGN KEY (CustomerKey) 
	REFERENCES dbo.DimCustomers (CustomerKey);
 
ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesOrderDateToDimDates FOREIGN KEY (OrderDateKey) 
	REFERENCES dbo.DimDates(CalendarDateKey);

ALTER TABLE dbo.FactSales ADD CONSTRAINT
	fkFactSalesShipDateDimDates FOREIGN KEY (ShipDateKey)
	REFERENCES dbo.DimDates (CalendarDateKey);
 
 
--********************************************************************--
-- Verify that the tables are filled
--********************************************************************--
-- Dimension Tables
SELECT * FROM [DWAdventureWorksLT2012Lab01].[dbo].[DimCustomers]; 
SELECT * FROM [DWAdventureWorksLT2012Lab01].[dbo].[DimProducts]; 
SELECT * FROM [DWAdventureWorksLT2012Lab01].[dbo].[DimDates]; 

-- Fact Tables 
SELECT * FROM [DWAdventureWorksLT2012Lab01].[dbo].[FactSales]; 
