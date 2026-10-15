# SQL Data Warehouse Project

A completed SQL Server data warehouse project built on the Medallion architecture for CRM and ERP integration, data cleansing, and analytical reporting.

## About the Project

This repository demonstrates a practical end-to-end data engineering workflow:

- ingest raw CRM and ERP data from CSV files
- land it in a Bronze layer
- clean and standardize it in a Silver layer
- expose curated business-ready models in a Gold layer

The project is designed as a learning-focused implementation that reflects common warehouse patterns used in real-world analytics environments.

## Project Status

Project status: Complete

This project was built and validated as a working SQL data warehouse example. The Bronze, Silver, and Gold layers are implemented and the repository is ready to be used as a reference or starting point for similar data warehouse work.

## Architecture

| Layer | Purpose | Status |
| --- | --- | --- |
| Bronze | Raw ingestion from source files | Complete |
| Silver | Cleaning, standardization, and validation | Complete |
| Gold | Business-ready analytics layer with curated views | Complete |

![Data Warehouse Architecture](Docs/Data%20Architecture%20Diagram.jpg)

## Business Objective

The goal of this project is to create a simplified but realistic enterprise data warehouse that combines customer, product, and sales data from multiple source systems. The resulting model supports downstream reporting and analytical exploration using a star-schema-style design.

## Source Systems

The project works with data from two source domains:

- CRM data
- ERP data

These datasets are transformed into a unified warehouse model to support reporting across customer and product dimensions.

## Repository Structure

```text
SQL-Data-Warehouse-Project/
├── README.md
├── LICENSE
├── Docs/
│   ├── Data Architecture Diagram.jpg
│   ├── Data Flow Diagram.jpg
│   ├── Data model (star schema).jpg
│   ├── Integration Model Diagram (Gold).jpg
│   ├── Integration Model Diagram.jpg
│   └── data_catalog.md
├── Scripts/
│   ├── init_database.sql
│   ├── bronze/
│   │   ├── init_tables_bronze.sql
│   │   └── sp_load_bronze.sql
│   ├── silver/
│   │   ├── init_table_silver.sql
│   │   └── sp_load_silver.sql
│   └── gold/
│       └── init_view_gold.sql
├── datasets/
│   ├── source_crm/
│   │   ├── cust_info.csv
│   │   ├── prd_info.csv
│   │   └── sales_details.csv
│   └── source_erp/
│       ├── CUST_AZ12.csv
│       ├── LOC_A101.csv
│       └── PX_CAT_G1V2.csv
└── LICENSE
```

## What This Project Delivers

- A SQL Server database named `DataWarehouse`
- Bronze-layer raw storage for source files
- Silver-layer cleaned and standardized datasets
- Gold-layer analytical views for reporting
- Integration of CRM and ERP data through a warehouse model
- A reusable project starter for analytics and warehouse learning

## Layer Overview

### Bronze Layer

The Bronze layer holds raw data as imported from CSV files without heavy transformation.

- `bronze_crm_cust_info`
- `bronze_crm_prd_info`
- `bronze_crm_sales_details`
- `bronze_erp_cust_az12`
- `bronze_erp_loc_a101`
- `bronze_erp_px_cat_g1v2`

This layer preserves source fidelity for auditability and traceability.

### Silver Layer

The Silver layer cleans and standardizes raw records for downstream processing.

- `silver_crm_cust_info`
- `silver_crm_prd_info`
- `silver_crm_sales_details`
- `silver_erp_cust_az12`
- `silver_erp_loc_a101`
- `silver_erp_px_cat_g1v2`

This layer creates a trusted and query-ready foundation for analytical work.

### Gold Layer

The Gold layer contains curated business models exposed for reporting.

- `gold.dim_customer`
- `gold.dim_products`
- `gold.fact_sales`

These views simplify analytical queries and support dimensional analysis and business reporting.

## Files and Scripts

- [`Scripts/init_database.sql`](Scripts/init_database.sql) - creates the warehouse database and required schemas
- [`Scripts/bronze/init_tables_bronze.sql`](Scripts/bronze/init_tables_bronze.sql) - creates the Bronze-layer tables
- [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql) - loads raw CSV files into Bronze
- [`Scripts/silver/init_table_silver.sql`](Scripts/silver/init_table_silver.sql) - creates the Silver-layer tables
- [`Scripts/silver/sp_load_silver.sql`](Scripts/silver/sp_load_silver.sql) - cleans and transforms the data
- [`Scripts/gold/init_view_gold.sql`](Scripts/gold/init_view_gold.sql) - creates the Gold-layer views
- [`Docs/data_catalog.md`](Docs/data_catalog.md) - documents the warehouse objects, columns, and relationships

## Data Catalog

The [data catalog](Docs/data_catalog.md) documents the tables, views, and columns used throughout the project. It explains the purpose of each object and clarifies how the datasets relate to each other.

## Setup and Execution

### Requirements

- SQL Server
- SSMS or Azure Data Studio
- Permissions to create databases, schemas, tables, and procedures
- Access to run `BULK INSERT`

### Run the Project

1. Update the file paths in [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql).
2. Run [`Scripts/init_database.sql`](Scripts/init_database.sql).
3. Run [`Scripts/bronze/init_tables_bronze.sql`](Scripts/bronze/init_tables_bronze.sql).
4. Run [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql).
5. Run [`Scripts/silver/init_table_silver.sql`](Scripts/silver/init_table_silver.sql).
6. Run [`Scripts/silver/sp_load_silver.sql`](Scripts/silver/sp_load_silver.sql).
7. Run [`Scripts/gold/init_view_gold.sql`](Scripts/gold/init_view_gold.sql).

> Important: these scripts may drop and recreate the `DataWarehouse` database. Back up any relevant data before running them.

## Validation

### Check Bronze Tables

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

### Check Silver Tables

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

## Completion Notes

This repository represents a finished data warehouse project focused on practical implementation and learning. It covers key data engineering tasks including extraction, ingestion, staging, transformation, dimensional modeling, and warehouse-ready reporting.

The project is now closed as a completed implementation and can be used as a reference for similar warehouse development work.

## License

This project is distributed under the [MIT License](LICENSE).
