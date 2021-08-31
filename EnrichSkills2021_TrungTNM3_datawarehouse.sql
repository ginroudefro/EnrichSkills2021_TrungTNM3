SET NOCOUNT ON
GO

USE master
GO
if exists (select * from sysdatabases where name='EnrichSkills2021_TrungTNM3')
		drop database EnrichSkills2021_TrungTNM3
go

DECLARE @device_directory NVARCHAR(520)
SELECT @device_directory = SUBSTRING(filename, 1, CHARINDEX(N'master.mdf', LOWER(filename)) - 1)
FROM master.dbo.sysaltfiles WHERE dbid = 1 AND fileid = 1

EXECUTE (N'CREATE DATABASE EnrichSkills2021_TrungTNM3
  ON PRIMARY (NAME = N''EnrichSkills2021_TrungTNM3'', FILENAME = N''' + @device_directory + N'es2021.mdf'')
  LOG ON (NAME = N''EnrichSkills2021_TrungTNM3_log'',  FILENAME = N''' + @device_directory + N'es2021.ldf'')')
go

if CAST(SERVERPROPERTY('ProductMajorVersion') AS INT)<12 
BEGIN
  exec sp_dboption 'EnrichSkills2021_TrungTNM3','trunc. log on chkpt.','true'
  exec sp_dboption 'EnrichSkills2021_TrungTNM3','select into/bulkcopy','true'
END
ELSE ALTER DATABASE [EnrichSkills2021_TrungTNM3] SET RECOVERY SIMPLE WITH NO_WAIT
GO

set quoted_identifier on
GO

/* Set DATEFORMAT so that the date strings are interpreted correctly regardless of
   the default DATEFORMAT on the server.
*/
SET DATEFORMAT mdy
GO
use "EnrichSkills2021_TrungTNM3"
go
if exists (select * from sysobjects where id = object_id('dbo.factOrder Details') and sysstat & 0xf = 3)
	drop table "dbo"."factOrder Details"
GO
if exists (select * from sysobjects where id = object_id('dbo.factOrders') and sysstat & 0xf = 3)
	drop table "dbo"."factOrders"
GO
if exists (select * from sysobjects where id = object_id('dbo.dimProducts') and sysstat & 0xf = 3)
	drop table "dbo"."dimProducts"
GO
if exists (select * from sysobjects where id = object_id('dbo.dimCustomers') and sysstat & 0xf = 3)
	drop table "dbo"."dimCustomers"
GO
if exists (select * from sysobjects where id = object_id('dbo.dimEmployees') and sysstat & 0xf = 3)
	drop table "dbo"."dimEmployees"
GO
if exists (select * from sysobjects where id = object_id('dbo.dimSupervisors') and sysstat & 0xf = 3)
	drop table "dbo"."dimSupervisors"
GO

CREATE TABLE "dimEmployees" (
	"EmployeeID" "int" NOT NULL ,
	"LastName" nvarchar (20) NOT NULL ,
	"FirstName" nvarchar (10) NOT NULL ,
	"Title" nvarchar (30) NULL ,
	"TitleOfCourtesy" nvarchar (25) NULL ,
	"BirthDate" "datetime" NULL ,
	"HireDate" "datetime" NULL ,
	"Address" nvarchar (60) NULL ,
	"City" nvarchar (15) NULL ,
	"Region" nvarchar (15) NULL ,
	"PostalCode" nvarchar (10) NULL ,
	"Country" nvarchar (15) NULL ,
	"HomePhone" nvarchar (24) NULL ,
	"Extension" nvarchar (4) NULL ,
	"Photo" "image" NULL ,
	"Notes" "ntext" NULL ,
	"ReportsTo" "int" NULL ,
	"PhotoPath" nvarchar (255) NULL
)
GO

CREATE TABLE "dimSupervisors" (
	"EmployeeID" "int" NOT NULL ,
	"LastName" nvarchar (20) NOT NULL ,
	"FirstName" nvarchar (10) NOT NULL ,
	"Title" nvarchar (30) NULL ,
	"TitleOfCourtesy" nvarchar (25) NULL ,
	"BirthDate" "datetime" NULL ,
	"HireDate" "datetime" NULL ,
	"Address" nvarchar (60) NULL ,
	"City" nvarchar (15) NULL ,
	"Region" nvarchar (15) NULL ,
	"PostalCode" nvarchar (10) NULL ,
	"Country" nvarchar (15) NULL ,
	"HomePhone" nvarchar (24) NULL ,
	"Extension" nvarchar (4) NULL ,
	"Photo" "image" NULL ,
	"Notes" "ntext" NULL ,
	"ReportsTo" "int" NULL ,
	"PhotoPath" nvarchar (255) NULL
)
GO

CREATE TABLE "dimCustomers" (
	"CustomerID" nchar (5) NOT NULL ,
	"CompanyName" nvarchar (40) NOT NULL ,
	"ContactName" nvarchar (30) NULL ,
	"ContactTitle" nvarchar (30) NULL ,
	"Address" nvarchar (60) NULL ,
	"City" nvarchar (15) NULL ,
	"Region" nvarchar (15) NULL ,
	"PostalCode" nvarchar (10) NULL ,
	"Country" nvarchar (15) NULL ,
	"Phone" nvarchar (24) NULL ,
	"Fax" nvarchar (24) NULL
)
GO

CREATE TABLE "factOrders" (
	"OrderID" "int" NOT NULL ,
	"CustomerID" nchar (5) NULL ,
	"EmployeeID" "int" NULL ,
	"OrderDate" "datetime" NULL ,
	"RequiredDate" "datetime" NULL ,
	"ShippedDate" "datetime" NULL ,
	"ShipVia" "int" NULL ,
	"Freight" "money" NULL ,
	"ShipName" nvarchar (40) NULL ,
	"ShipAddress" nvarchar (60) NULL ,
	"ShipCity" nvarchar (15) NULL ,
	"ShipRegion" nvarchar (15) NULL ,
	"ShipPostalCode" nvarchar (10) NULL ,
	"ShipCountry" nvarchar (15) NULL 
)
GO

CREATE TABLE "dimProducts" (
	"ProductID" "int" NOT NULL ,
	"ProductName" nvarchar (40) NOT NULL ,
	"SupplierID" "int" NULL ,
	"CompanyName" nvarchar (40) NOT NULL ,
	"ContactName" nvarchar (30) NULL ,
	"ContactTitle" nvarchar (30) NULL ,
	"Address" nvarchar (60) NULL ,
	"City" nvarchar (15) NULL ,
	"Region" nvarchar (15) NULL ,
	"PostalCode" nvarchar (10) NULL ,
	"Country" nvarchar (15) NULL ,
	"Phone" nvarchar (24) NULL ,
	"Fax" nvarchar (24) NULL ,
	"HomePage" "ntext" NULL ,
	"CategoryID" "int" NULL ,
	"CategoryName" nvarchar (15) NOT NULL ,
	"Description" "ntext" NULL ,
	"Picture" "image" NULL ,
	"QuantityPerUnit" nvarchar (20) NULL ,
	"UnitPrice" "money" NULL ,
	"UnitsInStock" "smallint" NULL ,
	"UnitsOnOrder" "smallint" NULL ,
	"ReorderLevel" "smallint" NULL ,
	"Discontinued" "bit" NOT NULL 
)
GO

CREATE TABLE "factOrder Details" (
	"OrderID" "int" NOT NULL ,
	"ProductID" "int" NOT NULL ,
	"UnitPrice" "money" NOT NULL ,
	"Quantity" "smallint" NOT NULL ,
	"Discount" "real" NOT NULL 
)
GO