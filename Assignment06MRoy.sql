--*************************************************************************--
-- Title: Assignment06
-- Author: Michelle Roy
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2020-08-11,Michelle Roy,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MichelleRoy')
	 Begin 
	  Alter Database [Assignment06DB_MichelleRoy] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MichelleRoy;
	 End
	Create Database Assignment06DB_MichelleRoy;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MichelleRoy;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!
Use Assignment06DB_MichelleRoy;
Go
Create  -- Drop
	View vCategories
	With Schemabinding
		As
		Select 
			CategoryID
			,CategoryName
	From dbo.Categories;
Go

Go
Create  -- Drop
	View vProducts
	With Schemabinding
		As
		Select 
			ProductID
			,ProductName
			,CategoryID
			,UnitPrice
	From dbo.Products;
Go

Go
Create  -- Drop
	View vEmployees
	With Schemabinding
		As
		Select 
			EmployeeID
			,EmployeeFirstName
			,EmployeeLastName
			,ManagerID
	From dbo.Employees;
Go

Go
Create  -- Drop
	View vInventories
	With Schemabinding
		As
		Select 
			InventoryID
			,InventoryDate
			,EmployeeID
			,ProductID
			,[Count]
	From dbo.Inventories;
Go

-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
Use Assignment06DB_MichelleRoy;
Deny Select On Categories to Public;
Grant Select On vCategories to Public;
Deny Select On Products to Public;
Grant Select On vProducts to Public;
Deny Select on Employees to Public;
Grant Select on vEmployees to Public;
Deny Select on Inventories to Public;
Grant Select on vInventories to Public;

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!
Go
Create -- Drop
	View vCategoryProductNamesPrice
		As
		Select Top 1000000000
		CategoryName
		,ProductName
		,UnitPrice
	From Categories Inner Join Products
	On Categories.CategoryID = Products.CategoryID
	Order by CategoryName, ProductName;
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!
Go
Create -- Drop
	View vProductNamesInventoryCountsbyInventoryDate
		As
		Select Top 1000000000
		ProductName
		,InventoryDate
		,[Count]
	From Products Inner Join Inventories
	On Products.ProductID = Inventories.ProductID
	Order by  ProductName,InventoryDate,  [Count];
Go	

Go
-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!
Go
Create
	View vInventoryDateByEmployee
		As
		Select Distinct Top 1000000000
		InventoryDate
		,[Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
	From Inventories Inner Join Employees
	On Employees.EmployeeID = Inventories.EmployeeID
    Order by InventoryDate;
Go

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!
Go
Create
	View vCategoriesProductsInvDateCount
		As
		Select Top 1000000000
		CategoryName
		,ProductName
		,InventoryDate
		,[Count]
	From Categories Inner Join Products
	On Categories.CategoryID = Products.CategoryID
	Inner Join Inventories
    On Products.ProductID = Inventories.ProductID
	Order by CategoryName, ProductName, InventoryDate, [Count];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!
Go
Create
	View vCategoriesProductsInvDateCountEmployee
		As
		Select Top 1000000000
			CategoryName
			,ProductName
			,InventoryDate
			,[Count]
			,[Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
		From Categories Inner Join Products
		On Categories.CategoryID = Products.CategoryID
		Inner Join Inventories
		On Products.ProductID = Inventories.ProductID
		Inner Join Employees
		On Employees.EmployeeID = Inventories.EmployeeID
		Order by InventoryDate, CategoryName, ProductName, [Employee Name];
Go

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 
Go
Create
	View vInventoriesForChaiAndChangByEmployees
		As
		Select Top 1000000000
			CategoryName
			,ProductName
			,InventoryDate
			,[Count]
			,[Employee Name] = EmployeeFirstName + ' ' + EmployeeLastName
		From Categories Inner Join Products
		On Categories.CategoryID = Products.CategoryID
		Inner Join Inventories
		On Products.ProductID = Inventories.ProductID
		Inner Join Employees
		On Employees.EmployeeID = Inventories.EmployeeID
	    Where Products.ProductID In (Select ProductID From Products Where ProductName In  ('Chai', 'Chang'))
	    Order by InventoryDate, CategoryName, ProductName;

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King


-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!
Go
Create 
	View vEmployeesByManager
		As
		Select Top 1000000000
			[Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
			,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
		From Employees E Inner Join Employees M
		On E.ManagerID = M.EmployeeID
	    Order by Manager, Employee;
Go
-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?
Go
Create -- Drop
	View vInventoriesByProductsByCategoriesByEmployees
		As 
		Select Top 1000000000			
			C.CategoryID
			,C.CategoryName
			,P.ProductID
			,P.ProductName
			,P.UnitPrice
			,I.InventoryID
			,I.InventoryDate
			,I.[Count]
			,E.EmployeeID
			,[Employee] = E.EmployeeFirstName + ' ' + E.EmployeeLastName
			,[Manager] = M.EmployeeFirstName + ' ' + M.EmployeeLastName
 		From vCategories As C
		Inner Join vProducts As P
		On C.CategoryID = P.CategoryID
		Inner Join vInventories As I
		On P.ProductID = I.ProductID
		Inner Join vEmployees as E
		On I.EmployeeID = E.EmployeeID
		Inner Join vEmployees as M
		On E.ManagerID = M.EmployeeID
		Order By CategoryID, CategoryName, ProductName, InventoryDate;
Go

--Will need to figure out this one maybeUnion clause??

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vCategoryProductNamesPrice]
Select * From [dbo].[vProductNamesInventoryCountsbyInventoryDate]
Select * From [dbo].[vInventoryDateByEmployee]
Select * From [dbo].[vCategoriesProductsInvDateCount]
Select * From [dbo].[vCategoriesProductsInvDateCountEmployee]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/