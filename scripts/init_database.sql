
--------------SQL DataWarehouse Project-------------

use master;
GO

--check if database 'DataWarehouse' already exists --
--Drop and recreate database 'DataWarehouse'--
IF EXISTS(select 1 from sys.databases where name = 'DataWarehouse')
BEGIN
	ALTER database DataWarehouse SET Single_user with rollback immediate;
	DROP database DataWarehouse;
END;
GO

--create database 'DataWarehouse'--
create database DataWarehouse;
GO
use DataWarehouse;
GO

--create Schemas --
create schema bronze;
GO
create schema silver;
GO
create schema gold;
