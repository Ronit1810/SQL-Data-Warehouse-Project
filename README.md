# SQL Data Warehouse Project

A simple SQL Server data warehouse project using the Medallion architecture for CRM and ERP data.

## About Me

### Ronit B Patel

I am a data engineering learner building practical SQL projects for data ingestion, cleaning, and analytics.

## Project Goal

This project loads raw CRM and ERP data into a SQL Server warehouse, cleans it in the Silver layer, and prepares it for analytics and reporting.

## Architecture

| Layer | Purpose | Status |
| --- | --- | --- |
| Bronze | Raw ingestion from source files | Complete |
| Silver | Cleaning, standardization, and validation | Complete |
| Gold | Business-ready analytics layer with curated views | Complete |

![Data Warehouse Architecture](Docs/Data%20Architecture%20Diagram.jpg)

## Project Structure

```text
SQL-Data-Warehouse-Project/
├── README.md
├── LICENSE
├── Docs/
│   ├── Data Architecture Diagram.jpg
│   ├── Integration Model Diagram.jpg
│   └── data_catalog.md
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
└── Scripts/
    ├── init_database.sql
    ├── bronze/
    │   ├── init_tables_bronze.sql
    │   └── sp_load_bronze.sql
    ├── silver/
    │   ├── init_table_silver.sql
    │   └── sp_load_silver.sql
    └── gold/
        └── init_view_gold.sql
```

## What This Project Does

- Creates the `DataWarehouse` database
- Ingests CRM and ERP files into Bronze tables
- Cleans and standardizes data in Silver tables
- Builds Gold-layer business views for dimensional reporting and fact analysis
- Exposes analytics-ready structures such as customer, product, and sales views

## Files and Scripts

- [`Scripts/init_database.sql`](Scripts/init_database.sql) - creates the database and schemas
- [`Scripts/bronze/init_tables_bronze.sql`](Scripts/bronze/init_tables_bronze.sql) - creates the Bronze tables
- [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql) - loads raw CSV files into Bronze
- [`Scripts/silver/init_table_silver.sql`](Scripts/silver/init_table_silver.sql) - creates the Silver tables
- [`Scripts/silver/sp_load_silver.sql`](Scripts/silver/sp_load_silver.sql) - cleans and transforms data into Silver
- [`Scripts/gold/init_view_gold.sql`](Scripts/gold/init_view_gold.sql) - creates the Gold analytical views
- [`Docs/data_catalog.md`](Docs/data_catalog.md) - documents the tables and views, column data types, plain-language meanings, example values, and relationships

### Data Catalog

The [data catalog](Docs/data_catalog.md) is a guide for analysts and other project users. It describes what information is stored in each Bronze and Silver table and Gold view, explains each column in plain language, shows representative example values, and summarizes how the datasets connect.

Start with the Gold views for business reporting. Refer to Bronze and Silver tables when tracing source data or investigating how it was prepared. Example values illustrate the expected format and may not represent every possible value.

## Bronze Layer Overview

The Bronze layer stores raw source data ingested straight from CSV files without heavy transformation.

- `bronze_crm_cust_info` - raw CRM customer information imported from source files.
- `bronze_crm_prd_info` - raw CRM product master data.
- `bronze_crm_sales_details` - raw sales transactions from CRM.
- `bronze_erp_cust_az12` - raw ERP customer demographic data.
- `bronze_erp_loc_a101` - raw ERP location information.
- `bronze_erp_px_cat_g1v2` - raw ERP product category mapping data.

This layer preserves the original data for audit, traceability, and recovery before cleansing.

## Silver Layer Overview

The Silver layer standardizes and cleans the raw data for downstream analytics.

- `silver_crm_cust_info` - cleaned CRM customer records with standardized fields and consistent formats.
- `silver_crm_prd_info` - cleaned product master data for reporting and product analysis.
- `silver_crm_sales_details` - validated sales fact records prepared for analytical joins.
- `silver_erp_cust_az12` - normalized ERP customer details for enrichment.
- `silver_erp_loc_a101` - cleaned location data used for customer country mapping.
- `silver_erp_px_cat_g1v2` - standardized ERP category metadata used in product dimensions.

This layer creates the trusted, query-ready foundation used by the Gold layer.

## Gold Layer Overview

The Gold layer provides business-ready views for analytics and reporting.

- `gold.dim_customer` - customer dimension built from CRM customer details and ERP demographic/location data.
- `gold.dim_products` - current product dimension with active records only, excluding historical product versions.
- `gold.fact_sales` - sales fact table that links transaction records to product and customer dimensions.

These views make downstream BI queries simpler and support common star-schema reporting patterns.

## Setup

### Requirements

- SQL Server
- SSMS or Azure Data Studio
- Permissions to create database, schemas, tables, and procedures
- Permission to run `BULK INSERT`

### Run the Project

1. Update the file paths in [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql).
2. Run [`Scripts/init_database.sql`](Scripts/init_database.sql).
3. Run [`Scripts/bronze/init_tables_bronze.sql`](Scripts/bronze/init_tables_bronze.sql).
4. Run [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql).
5. Run [`Scripts/silver/init_table_silver.sql`](Scripts/silver/init_table_silver.sql).
6. Run [`Scripts/silver/sp_load_silver.sql`](Scripts/silver/sp_load_silver.sql).
7. Run [`Scripts/gold/init_view_gold.sql`](Scripts/gold/init_view_gold.sql) to create the Gold-layer customer, product, and sales views.

> Important: this project drops the `DataWarehouse` database and truncates tables during setup. Back up anything important before running the scripts.

## Validation

Check Bronze tables:

```sql
USE DataWarehouse;
GO

SELECT 'bronze_crm_cust_info' AS table_name, COUNT(*) AS row_count FROM bronze_crm_cust_info
UNION ALL SELECT 'bronze_crm_prd_info', COUNT(*) FROM bronze_crm_prd_info
UNION ALL SELECT 'bronze_crm_sales_details', COUNT(*) FROM bronze_crm_sales_details
UNION ALL SELECT 'bronze_erp_cust_az12', COUNT(*) FROM bronze_erp_cust_az12
UNION ALL SELECT 'bronze_erp_loc_a101', COUNT(*) FROM bronze_erp_loc_a101
UNION ALL SELECT 'bronze_erp_px_cat_g1v2', COUNT(*) FROM bronze_erp_px_cat_g1v2;
```

Check Silver tables:

```sql
USE DataWarehouse;
GO

SELECT 'silver_crm_cust_info' AS table_name, COUNT(*) AS row_count FROM silver_crm_cust_info
UNION ALL SELECT 'silver_crm_prd_info', COUNT(*) FROM silver_crm_prd_info
UNION ALL SELECT 'silver_crm_sales_details', COUNT(*) FROM silver_crm_sales_details
UNION ALL SELECT 'silver_erp_cust_az12', COUNT(*) FROM silver_erp_cust_az12
UNION ALL SELECT 'silver_erp_loc_a101', COUNT(*) FROM silver_erp_loc_a101
UNION ALL SELECT 'silver_erp_px_cat_g1v2', COUNT(*) FROM silver_erp_px_cat_g1v2;
```

## Roadmap

- [x] Bronze ingestion setup
- [x] Silver cleaning and standardization
- [x] Key normalization and CRM/ERP integration
- [ ] Quality checks and rejected-record handling
- [x] Gold data models and business views
- [ ] Automation and reporting examples

## Project Status

Bronze, Silver, and Gold analytical views are in place. The project now provides a foundation for reporting and dashboard use cases using curated dimensions and fact views.

## License

This project is distributed under the [MIT License](LICENSE).
