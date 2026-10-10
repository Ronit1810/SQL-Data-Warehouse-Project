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
| Gold | Business-ready analytics layer | Planned |

![Data Warehouse Architecture](Docs/Data%20Architecture%20Diagram.jpg)

## Project Structure

```text
SQL-Data-Warehouse-Project/
├── README.md
├── LICENSE
├── Docs/
│   ├── Data Architecture Diagram.jpg
│   └── Integration Model Diagram.jpg
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
    └── silver/
        ├── init_table_silver.sql
        └── sp_load_silver.sql
```

## What This Project Does

- Creates the `DataWarehouse` database
- Ingests CRM and ERP files into Bronze tables
- Cleans and standardizes data in Silver tables
- Prepares the foundation for Gold analytics models

## Files and Scripts

- [`Scripts/init_database.sql`](Scripts/init_database.sql) - creates the database and schemas
- [`Scripts/bronze/init_tables_bronze.sql`](Scripts/bronze/init_tables_bronze.sql) - creates the Bronze tables
- [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql) - loads raw CSV files into Bronze
- [`Scripts/silver/init_table_silver.sql`](Scripts/silver/init_table_silver.sql) - creates the Silver tables
- [`Scripts/silver/sp_load_silver.sql`](Scripts/silver/sp_load_silver.sql) - cleans and transforms data into Silver

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
- [ ] Key normalization and CRM/ERP integration
- [ ] Quality checks and rejected-record handling
- [ ] Gold data models and business views
- [ ] Automation and reporting examples

## Project Status

Bronze and Silver layers are complete. Gold analytical modeling is the next step.

## License

This project is distributed under the [MIT License](LICENSE).
