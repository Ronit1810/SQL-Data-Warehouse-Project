

/*
==============================================================================================
 Script:       sp_load_silver.sql
 Purpose:      Refresh the silver layer by transforming bronze source data into curated,
               standardized warehouse tables for downstream reporting and analytics.
 Description:  This stored procedure loads incremental, cleaned CRM and ERP data into the
               silver layer using a truncate-and-reload pattern for each target table.
 Notes:        Silver tables are the curated, business-ready data warehouse layer. Each
               target table is truncated before the latest validated bronze records are
               inserted, ensuring a consistent and reproducible dataset for analysis.
==============================================================================================
*/

CREATE OR ALTER PROCEDURE sp_load_silver AS 
BEGIN
        DECLARE @start_time DATETIME, 
            @end_time DATETIME;
    BEGIN TRY
        -- Execute the silver-layer refresh. Each target table is intentionally truncated and
        -- repopulated to guarantee the latest curated dataset is available for downstream use.
        PRINT NCHAR(13);     -- Add a line break for readability in the output.

        PRINT '=======================================';
        PRINT 'Loading data into Silver tables...';
        PRINT '=======================================';


        -- CRM source loads: standardize customer, product, and sales records into the silver layer.
        PRINT NCHAR(13);     -- Add a line break for readability in the output.
        PRINT '---------------- CRM DATA ----------------';
        PRINT NCHAR(13);     -- Add a line break for readability in the output.
        SET @start_time = GETDATE();
        -- Load the latest CRM customer master records and normalize name, marital status, and gender values.
        -- Keep only the most recent record per customer ID to avoid duplicate active customer profiles.
        PRINT '>> Truncating table - silver_crm_cust_info'
        TRUNCATE TABLE silver_crm_cust_info
        PRINT '--Inserting Data - silver_crm_cust_info'
        INSERT INTO silver_crm_cust_info(     [cst_id],
            [cst_key],
            [cst_firstname],
            [cst_lastname],
            [cst_marital_status],
            [cst_gndr],
            [cst_create_date]
        )
        SELECT
            [cst_id],
            [cst_key],
            TRIM(cst_firstname) AS cst_firstname,  -- Remove leading and trailing whitespace from first names
            TRIM(cst_lastname) AS cst_lastname,  -- Remove leading and trailing whitespace from last names

            CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
                WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
            ELSE 'n/a'
            END AS cst_marital_status,  -- Standardize marital status into readable business values

            CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
                WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
            ELSE 'n/a'
            END AS cst_gndr,  -- Standardize gender values into consistent labels

            [cst_create_date]
        FROM(
            SELECT
                *,
                ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY [cst_create_date] DESC) AS flag_last
            FROM bronze_crm_cust_info
            WHERE cst_id IS NOT NULL
        )t
        WHERE flag_last = 1  -- Keep only the most recent customer record for each customer ID

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_crm_cust_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for readability in the output.


        SET @start_time = GETDATE();
        -- Load the CRM product dimension and normalize category keys, lifecycle dates, and product lines.
        PRINT '>> Truncating table - silver_crm_prd_info'
        TRUNCATE TABLE silver_crm_prd_info
        PRINT '--Inserting Data - silver_crm_prd_info'
        INSERT INTO silver_crm_prd_info (
            [prd_id],
            [cat_id],
            [prd_key],
            [prd_nm],
            [prd_cost],
            [prd_line],
            [prd_start_dt],
            [prd_end_dt]
        )
        SELECT
            [prd_id],
            REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
            SUBSTRING(prd_key, 7, len(prd_key)) AS prd_key,
            [prd_nm],
            COALESCE(prd_cost, 0) AS prd_cost,
            CASE UPPER(TRIM(prd_line))
                WHEN 'M' THEN 'Mountain'
                WHEN 'R' THEN 'Road'
                WHEN 'S' THEN 'Other Sales'
                WHEN 'T' THEN 'Touring'
                ELSE 'n/a'
            END AS prd_line,
            CAST([prd_start_dt] AS DATE) AS prd_start_dt,
            CAST(LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt) - 1 AS DATE) AS prd_end_dt
        FROM bronze_crm_prd_info

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_crm_prd_info: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for readability in the output.

        SET @start_time = GETDATE();
        -- Load the CRM sales fact and normalize date fields and derived revenue values.
        -- Recalculate sales when source data is missing or inconsistent with quantity and price.
        PRINT '>> Truncating table - silver_crm_sales_details'
        TRUNCATE TABLE silver_crm_sales_details
        PRINT '--Inserting Data - silver_crm_sales_details'
        INSERT INTO silver_crm_sales_details(
            [sls_ord_num],
            [sls_cust_id],
            [sls_order_dt],
            [sls_prd_key],
            [sls_ship_dt],
            [sls_due_dt],
            [sls_sales],
            [sls_quantity],
            [sls_price]
        )
        SELECT
            [sls_ord_num],
            [sls_cust_id],
            CASE 
                WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
            END AS sls_order_dt,

            [sls_prd_key],

            CASE 
                WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
            END AS sls_ship_dt,

            CASE 
                WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
                ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
            END AS sls_due_dt,

            CASE
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price)
                    THEN sls_quantity * ABS(sls_price)
                ELSE sls_sales
            END AS sls_sales,

            [sls_quantity],

            CASE
                WHEN sls_price IS NULL OR sls_price <=0
                    THEN sls_sales / NULLIF(sls_quantity,0)
                ELSE sls_price
            END AS sls_price
        FROM bronze_crm_sales_details

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_crm_sales_details: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';




        PRINT NCHAR(13);     -- Add a line break for readability in the output.




        -- ERP source loads: harmonize customer, geography, and product metadata for analytics consistency.
        PRINT NCHAR(13);     -- Add a line break for readability in the output.
        PRINT '---------------- ERP DATA ----------------';
        PRINT NCHAR(13);     -- Add a line break for readability in the output.

        SET @start_time = GETDATE();
        -- Load ERP customer master records and normalize IDs, birth dates, and gender values.
        PRINT '>> Truncating table - silver_erp_cust_az12'
        TRUNCATE TABLE silver_erp_cust_az12
        PRINT '--Inserting Data - silver_erp_cust_az12'
        INSERT INTO silver_erp_cust_az12(
            [CID],
            [BDATE],
            [GEN]
        )
        SELECT
            CASE WHEN CID LIKE 'NAS%'
                THEN SUBSTRING(CID, 4, LEN(CID))
            ELSE CID
            END AS CID,

            CASE WHEN BDATE >= GETDATE()
                THEN NULL
            ELSE BDATE
            END AS BDATE,

            CASE WHEN UPPER(TRIM(GEN)) IN ('F', 'FEMALE') THEN 'Female'
                WHEN UPPER(TRIM(GEN)) IN ('M', 'MALE') THEN 'Male'
            ELSE GEN
            END AS GEN
        FROM [DataWarehouse].[dbo].[bronze_erp_cust_az12]

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_erp_cust_az12: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';




        PRINT NCHAR(13);     -- Add a line break for readability in the output.

        SET @start_time = GETDATE();
        -- Load the ERP location dimension and map country codes to readable display values.
        PRINT '>> Truncating table - silver_erp_loc_a101'
        TRUNCATE TABLE silver_erp_loc_a101
        PRINT '--Inserting Data - silver_erp_loc_a101'
        INSERT INTO silver_erp_loc_a101(
            [CID],
            [CNTRY]
        )
        SELECT
            REPLACE(CID, '-', '') AS CID,
            CASE WHEN TRIM(CNTRY) = 'DE' THEN 'Germany'
                WHEN TRIM(CNTRY) IN ('US', 'USA') THEN 'United States'
                WHEN TRIM(CNTRY) IS NULL OR TRIM(CNTRY) = '' THEN 'n/a'
            ELSE TRIM(CNTRY)
            END AS CNTRY
        FROM [DataWarehouse].[dbo].[bronze_erp_loc_a101]

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_erp_loc_a101: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';



        PRINT NCHAR(13);     -- Add a line break for readability in the output.


        SET @start_time = GETDATE();
        -- Load the ERP product category metadata with minimal transformation beyond validation.
        PRINT '>> Truncating table - silver_erp_px_cat_g1v2'
        TRUNCATE TABLE silver_erp_px_cat_g1v2
        PRINT '--Inserting Data - silver_erp_px_cat_g1v2'
        INSERT INTO silver_erp_px_cat_g1v2(
            [ID],
            [SUBCAT],
            [MAINTENANCE],
            [CAT]
        )
        SELECT
            [ID],
            [SUBCAT],
            [MAINTENANCE],
            [CAT]
        FROM [DataWarehouse].[dbo].[bronze_erp_px_cat_g1v2]

        SET @end_time = GETDATE();
        PRINT '> Time taken to load silver_erp_px_cat_g1v2: ' + CAST(DATEDIFF(SECOND, @start_time, @end_time) AS NVARCHAR(10)) + ' seconds';


        PRINT NCHAR(13);     -- Add a line break for readability in the output.
            
    END TRY
    BEGIN CATCH
        -- Surface the failure details for the silver-layer load and rethrow the original error.
        PRINT 'Error occurred while loading data into Silver tables.';
        PRINT 'Error Number: ' + CAST(ERROR_NUMBER() AS NVARCHAR(10));
        PRINT 'Error Message: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END

EXEC sp_load_silver
