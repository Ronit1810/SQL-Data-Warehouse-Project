

/*
==============================================================================================
 Script:       init_table_silver.sql
 Purpose:      Initialize the silver-layer tables in the DataWarehouse database.
 Description:  Create the CRM and ERP tables used to store cleansed and standardized
               source data for downstream reporting and analytics.
 Warning:      Existing tables with the same names are dropped and recreated. Any data in
               those tables will be permanently deleted when this script runs.
==============================================================================================
*/




-- Create the silver CRM customer table.
IF OBJECT_ID('silver_crm_cust_info', 'U') IS NOT NULL
    DROP TABLE silver_crm_cust_info;
CREATE TABLE silver_crm_cust_info(
    cst_id INT,
    cst_key NVARCHAR(50),
    cst_firstname NVARCHAR(50),
    cst_lastname NVARCHAR(50),
    cst_marital_status NVARCHAR(50),
    cst_gndr NVARCHAR(50),
        cst_create_date DATE,
        dwh_create_date DATETIME DEFAULT GETDATE()
);


-- Create the silver CRM product table.
IF OBJECT_ID('silver_crm_prd_info', 'U') IS NOT NULL
    DROP TABLE silver_crm_prd_info;
CREATE TABLE silver_crm_prd_info(
    prd_id INT,
    prd_key NVARCHAR(50),
    cat_id NVARCHAR(50),
    prd_nm NVARCHAR(50),
    prd_cost INT,
    prd_line NVARCHAR(50),
    prd_start_dt DATE,
    prd_end_dt DATE,
    dwh_create_date DATETIME DEFAULT GETDATE()
);


-- Create the silver CRM sales transaction table.
IF OBJECT_ID('silver_crm_sales_details', 'U') IS NOT NULL
    DROP TABLE silver_crm_sales_details;
CREATE TABLE silver_crm_sales_details(
    sls_ord_num NVARCHAR(50),
    sls_prd_key NVARCHAR(50),
    sls_cust_id INT,
    sls_order_dt DATE,
    sls_ship_dt DATE,
    sls_due_dt DATE,
    sls_sales INT,
    sls_quantity INT,
    sls_price INT,
    dwh_create_date DATETIME DEFAULT GETDATE()
);


-- Create the silver ERP customer table.
IF OBJECT_ID('silver_erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE silver_erp_cust_az12;
CREATE TABLE silver_erp_cust_az12(
    CID NVARCHAR(50),
    BDATE DATE,
    GEN NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT GETDATE()
);


-- Create the silver ERP customer location table.
IF OBJECT_ID('silver_erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE silver_erp_loc_a101;
CREATE TABLE silver_erp_loc_a101(
    CID NVARCHAR(50),
    CNTRY NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT GETDATE()
);


-- Create the silver ERP product category table.
IF OBJECT_ID('silver_erp_px_cat_g1v2', 'U') IS NOT NULL
    DROP TABLE silver_erp_px_cat_g1v2;
CREATE TABLE silver_erp_px_cat_g1v2(
    ID NVARCHAR(50),
    CAT NVARCHAR(50),
    SUBCAT NVARCHAR(50),
    MAINTENANCE NVARCHAR(50),
    dwh_create_date DATETIME DEFAULT GETDATE()
);



