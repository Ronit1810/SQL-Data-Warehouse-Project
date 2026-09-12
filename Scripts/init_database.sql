/*
==============================================================================================
 Script:       init_database.sql
 Purpose:      Initialize the DataWarehouse database and its medallion architecture schemas.
 Description:  Create the DataWarehouse database, then create the bronze, silver, and gold
               schemas used for raw, refined, and business-ready data.
 Warning:      If DataWarehouse already exists, this script drops it and permanently deletes
               all data. Back up any required data before running this script.
==============================================================================================
*/


USE master;
GO

-- Drop the existing database so the initialization can be rerun from a clean state.
IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'DataWarehouse')
BEGIN
    ALTER DATABASE DataWarehouse SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE DataWarehouse;
END;
GO


-- Create the empty DataWarehouse database.
CREATE DATABASE DataWarehouse;
GO


-- Switch to the newly created database before adding its schemas.
USE DataWarehouse
GO

-- Create the bronze schema for raw ingested data.
CREATE SCHEMA bronze;
GO

-- Create the silver schema for cleaned and transformed data.
CREATE SCHEMA silver;
GO

-- Create the gold schema for curated, business-ready data.
CREATE SCHEMA gold;
GO