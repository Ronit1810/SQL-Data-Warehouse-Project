

/*
==============================================================================================
 Script:       init_tables.sql
 Purpose:      Initialize the bronze-layer source tables in the DataWarehouse database.
 Description:  Create CRM and ERP source tables used to store raw data before cleansing
               and transformation.
 Warning:      Existing tables with the same names are dropped and recreated. Any data in
               those tables will be permanently deleted when this script runs.
==============================================================================================
*/




-- Create the bronze_crm_cust_info table.
IF OBJECT_ID('bronze_crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze_crm_cust_info;
CREATE TABLE bronze_crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
    cst_create_date DATE
);


-- Create the bronze_crm_prd_info table for raw CRM product data.
IF OBJECT_ID('bronze_crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze_crm_prd_info;
CREATE TABLE bronze_crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE
);


-- Create the bronze_crm_sales_details table for raw CRM sales transactions.
IF OBJECT_ID('bronze_crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze_crm_sales_details;
CREATE TABLE bronze_crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt INT,
    sls_ship_dt INT,
    sls_due_dt INT,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT
);


-- Create the bronze_erp_cust_az12 table for raw ERP customer data.
IF OBJECT_ID('bronze_erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze_erp_cust_az12;
CREATE TABLE bronze_erp_cust_az12(
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50)
);


-- Create the bronze_erp_loc_a101 table for raw ERP customer location data.
IF OBJECT_ID('bronze_erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze_erp_loc_a101;
CREATE TABLE bronze_erp_loc_a101(
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50)
);


-- Create the bronze_erp_px_cat_g1v2 table for raw ERP product category data.
IF OBJECT_ID('bronze_erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE bronze_erp_px_cat_g1v2;
CREATE TABLE bronze_erp_px_cat_g1v2(
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50)
);



