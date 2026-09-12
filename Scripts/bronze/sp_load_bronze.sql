

CREATE OR ALTER PROCEDURE sp_load_bronze AS 
BEGIN
    DECLARE @start_time DATETIME, 
            @end_time DATETIME;
    BEGIN TRY
            -- Load data into the bronze tables from CSV files.
        

        PRINT '=======================================';
        PRINT 'Loading data into bronze tables...';
        PRINT '=======================================';


        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        PRINT '---------------- CRM DATA----------------';
        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_crm_cust_info';
        TRUNCATE TABLE bronze_crm_cust_info;
        PRINT '> Loading data from CSV: cust_info.csv';
        BULK INSERT bronze_crm_cust_info
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_crm\cust_info.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for better readability in the output.

        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_crm_prd_info';
        TRUNCATE TABLE bronze_crm_prd_info;
        PRINT '> Loading data from CSV: prd_info.csv';
        BULK INSERT bronze_crm_prd_info
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_crm\prd_info.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        
        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_crm_sales_details';
        TRUNCATE TABLE bronze_crm_sales_details;
        PRINT '> Loading data from CSV: sales_details.csv';
        BULK INSERT bronze_crm_sales_details
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_crm\sales_details.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';




        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        PRINT '----------------ERP DATA----------------';
        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        
        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_erp_cust_az12';
        TRUNCATE TABLE bronze_erp_cust_az12;
        PRINT '> Loading data from CSV: cust_az12.csv';
        BULK INSERT bronze_erp_cust_az12
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_erp\cust_az12.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';




        PRINT NCHAR(13);     -- Add a line break for better readability in the output.

        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_erp_loc_a101';
        TRUNCATE TABLE bronze_erp_loc_a101;
        PRINT '> Loading data from CSV: loc_a101.csv';
        BULK INSERT bronze_erp_loc_a101
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_erp\loc_a101.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
        
        SET @start_time = GETDATE();
        PRINT '> Truncating Table: bronze_erp_px_cat_g1v2';
        TRUNCATE TABLE bronze_erp_px_cat_g1v2;
        PRINT '> Loading data from CSV: px_cat_g1v2.csv';
        BULK INSERT bronze_erp_px_cat_g1v2
        FROM "D:\SELF-PROJECT\DATA ENGINEERING PROJECT\SQL-Data-Warehouse-Project\datasets\source_erp\px_cat_g1v2.csv" --path to the source file
        WITH (
            FIELDTERMINATOR = ',',  -- Specify the field delimiter (comma for CSV)
            FIRSTROW = 2,  -- Skip the header row
            TABLOCK  -- Use table-level locking for better performance
        );
        SET @end_time = GETDATE();
        PRINT '> Time taken to load bronze_erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';
    
        PRINT NCHAR(13);     -- Add a line break for better readability in the output.
            
    END TRY
    BEGIN CATCH
        -- Handle any errors that occur during the data loading process
        PRINT 'Error occurred while loading data into bronze tables.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        THROW;
    END CATCH

END;



EXEC sp_load_bronze;