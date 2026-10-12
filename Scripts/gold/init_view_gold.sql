


/*
==============================================================================================
 Script:       init_view_gold.sql
 Purpose:      Create the gold-layer views used for dimensional reporting and analytics.
 Description:  Builds customer, product, and sales views that expose curated business data
               from the silver layer. These views provide a clean layer for BI, dashboards,
               and downstream analytical queries.
 Notes:        Views are read-only metadata objects; they do not store data. To update a
               view definition, use ALTER VIEW instead of TRUNCATE or a refresh command.
==============================================================================================
*/

-- Gold dimension: customer master data
-- Combines CRM customer info with ERP demographic and location dimensions.
-- ROW_NUMBER() creates a surrogate key for reporting and star-schema joins.
CREATE VIEW gold.dim_customer AS
SELECT
    ROW_NUMBER() OVER(ORDER BY cst_id) AS customer_key,   -- Surrogate key for dimension usage
    ci.[cst_id] AS customer_id,
    ci.[cst_key] AS customer_number,
    ci.[cst_firstname] AS first_name,
    ci.[cst_lastname] AS last_name,
    ci.[cst_marital_status] AS marital_status,
    CASE
        WHEN ci.cst_gndr != 'n/a' THEN ci.cst_gndr
        ELSE ca.GEN
    END AS gender,                             -- Prefer valid CRM gender; fallback to ERP value
    ca.[BDATE] AS birthdate,
    la.[CNTRY] AS country,
    ci.[cst_create_date] AS created_date
FROM silver_crm_cust_info AS ci
LEFT JOIN silver_erp_cust_az12 AS ca
    ON ci.cst_key = ca.CID
LEFT JOIN silver_erp_loc_a101 AS la
    ON ci.cst_key = la.CID;
GO

-- Gold dimension: active product catalog
-- Keeps only the current product version by excluding historical rows with an end date.
-- This ensures reporting reflects the latest active product state.
CREATE VIEW gold.dim_products AS
SELECT
    ROW_NUMBER() OVER(ORDER BY pi.[prd_id], pi.[prd_start_dt]) AS product_key,  -- Surrogate key
    pi.[prd_id] AS product_id,
    pi.[prd_key] AS product_number,
    pi.[prd_nm] AS product_name,
    pi.[prd_cost] AS product_cost,
    pi.[cat_id] AS category_id,
    pc.[CAT] AS category,
    pc.[SUBCAT] AS sub_category,
    pc.[MAINTENANCE],
    pi.[prd_line] AS product_line,
    pi.[prd_start_dt] AS start_date
FROM silver_crm_prd_info AS pi
LEFT JOIN silver_erp_px_cat_g1v2 AS pc
    ON pi.cat_id = pc.ID
WHERE pi.prd_end_dt IS NULL;  -- Retain only active/current records, excluding historical versions
GO

-- Gold fact: sales transactions for analytical reporting
-- Joins transactional sales data to product and customer dimensions using business keys.
CREATE VIEW gold.fact_sales AS
SELECT
    s.[sls_ord_num] AS order_number,
    p.[product_key],
    c.[customer_key],
    s.[sls_order_dt] AS order_date,
    s.[sls_ship_dt] AS shipping_date,
    s.[sls_due_dt] AS due_date,
    s.[sls_sales] AS sales_amount,
    s.[sls_quantity] AS quantity,
    s.[sls_price] AS price
FROM silver_crm_sales_details AS s
LEFT JOIN gold.dim_products AS p
    ON s.sls_prd_key = p.product_number
LEFT JOIN gold.dim_customer AS c
    ON s.sls_cust_id = c.customer_id;
GO

