

/*
==============================================================================================
 Script:       sp_load_silver.sql
 Purpose:      Load and standardize the silver-layer tables from bronze source data.
 Description:  Cleans CRM and ERP source records into curated silver tables for downstream
               reporting, modeling, and analytics use.
 Notes:        This script truncates each silver target table before reloading it with the
               latest validated data from the bronze layer. Silver tables are truncate and
               load tables for the curated data warehouse layer.
==============================================================================================
*/


-- Load cleaned customer master data from CRM bronze source.
-- Keep only the most recent customer record per customer ID and normalize name/gender/marital fields.
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
    TRIM(cst_firstname) AS cst_firstname,  -- Removed extra/unwanted spaces
    TRIM(cst_lastname) AS cst_lastname,  -- Removed extra/unwanted spaces

    CASE WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
        WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
    ELSE 'n/a'
    END AS cst_marital_status,  -- Normalization marital status to readable format

    CASE WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
        WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
    ELSE 'n/a'
    END AS cst_gndr,  --  Normalization gender to readable format

    [cst_create_date]
FROM(
    SELECT
        *,
        ROW_NUMBER() OVER(PARTITION BY cst_id ORDER BY [cst_create_date] DESC) AS flag_last
    FROM bronze_crm_cust_info
    WHERE cst_id IS NOT NULL
)t
WHERE flag_last = 1  --  adding only most recent record per customer


PRINT NCHAR(13);     -- Add a line break for readability in the output.


-- Load product dimension data from CRM bronze source.
-- Standardize category keys, product line values, and product lifecycle dates.
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



PRINT NCHAR(13);     -- Add a line break for readability in the output.


-- Load sales fact data from CRM bronze source.
-- Normalize dates and derive missing sales values from price and quantity when required.
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



PRINT NCHAR(13);     -- Add a line break for readability in the output.


-- Load ERP customer master records and normalize ID/date/gender columns for analytics consistency.
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



PRINT NCHAR(13);     -- Add a line break for readability in the output.


-- Load ERP location dimension and map country codes to human-readable values.
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


PRINT NCHAR(13);     -- Add a line break for readability in the output.


-- Load ERP product category metadata without transformation beyond source validation.
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

