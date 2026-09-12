# SQL Data Warehouse Project

<p align="center">
  <strong>SQL Server Data Warehouse with Medallion Architecture</strong><br>
  Raw CRM and ERP data prepared for reporting, analysis, and machine learning.
</p>



## About Me

### RONIT B PATEL

Data engineering learner building practical SQL Server solutions for ingestion, transformation, modeling, and analytics.

<p align="center">
  <a href="https://github.com/Ronit1810"><img src="https://img.shields.io/badge/GitHub-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub"></a>
  <a href="https://www.linkedin.com/in/ronit-patel-a023901a5/"><img src="https://img.shields.io/badge/LinkedIn-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white" alt="LinkedIn"></a>
  <a href="https://www.instagram.com/1810_ronitpatel?igshid=OGQ5ZDc2ODk2ZA%3D%3D"><img src="https://img.shields.io/badge/Instagram-E4405F?style=for-the-badge&logo=instagram&logoColor=white" alt="Instagram"></a>
  <a href="https://app.notion.com/p/Data-Warehouse-Project-SQL-3d8b691ce5c2800a9a4bf037ce687fb5?source=copy_link"><img src="https://img.shields.io/badge/Notion-000000?style=for-the-badge&logo=notion&logoColor=white" alt="Notion"></a>
</p>

## Project Overview

This project builds a SQL Server data warehouse using the **Medallion Architecture**:

| Layer      | Responsibility                                                  | Status   |
| ---------- | --------------------------------------------------------------- | -------- |
| **Bronze** | Stores raw CRM and ERP data with minimal changes.               | Complete |
| **Silver** | Cleans, standardizes, validates, and integrates data.           | Planned  |
| **Gold**   | Publishes business-ready views, facts, dimensions, and metrics. | Planned  |

![Data Warehouse Architecture](Docs/Data%20Architecture%20Diagram.jpg)

## Repository Structure

```text
SQL-Data-Warehouse-Project/
|-- README.md
|-- LICENSE
|-- Docs/
|   `-- Data Architecture Diagram.jpg
|-- datasets/
|   |-- source_crm/
|   |   |-- cust_info.csv
|   |   |-- prd_info.csv
|   |   `-- sales_details.csv
|   `-- source_erp/
|       |-- CUST_AZ12.csv
|       |-- LOC_A101.csv
|       `-- PX_CAT_G1V2.csv
`-- Scripts/
    |-- init_database.sql
    `-- bronze/
        |-- init_tables.sql
        `-- sp_load_bronze.sql
```

## Source Data and Bronze Tables

| Source file         | Contents                                                | Bronze table               |
| ------------------- | ------------------------------------------------------- | -------------------------- |
| `cust_info.csv`     | CRM customer details and demographics                   | `bronze_crm_cust_info`     |
| `prd_info.csv`      | CRM products, costs, categories, and dates              | `bronze_crm_prd_info`      |
| `sales_details.csv` | Orders, products, customers, dates, sales, and quantity | `bronze_crm_sales_details` |
| `CUST_AZ12.csv`     | ERP customer birth dates and gender                     | `bronze_erp_cust_az12`     |
| `LOC_A101.csv`      | ERP customer locations and countries                    | `bronze_erp_loc_a101`      |
| `PX_CAT_G1V2.csv`   | ERP product categories and maintenance data             | `bronze_erp_px_cat_g1v2`   |

The Bronze tables preserve raw source columns. They currently have no keys, indexes, audit columns, or data-quality constraints because cleansing is planned for Silver.

## SQL Scripts

- [`Scripts/init_database.sql`](Scripts/init_database.sql) creates the `DataWarehouse` database and the `bronze`, `silver`, and `gold` schemas.
- [`Scripts/bronze/init_tables.sql`](Scripts/bronze/init_tables.sql) drops and recreates the six Bronze tables.
- [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql) creates `sp_load_bronze`, truncates each target table, and loads all six CSV files with `BULK INSERT`.

The loader skips CSV header rows, uses comma delimiters and table-level locking, prints load duration, separates CRM and ERP output, and rethrows errors after reporting them.

## Setup and Execution

### Requirements

- SQL Server on Windows
- SQL Server Management Studio or Azure Data Studio
- Permission to create/drop databases, schemas, tables, and procedures
- Permission for `BULK INSERT`
- SQL Server service-account access to the dataset folder

### Run the project

1. Update the absolute file paths in `sp_load_bronze.sql` so they are accessible to the SQL Server machine.
2. Run [`Scripts/init_database.sql`](Scripts/init_database.sql).
3. Switch to the `DataWarehouse` database.
4. Run [`Scripts/bronze/init_tables.sql`](Scripts/bronze/init_tables.sql).
5. Run [`Scripts/bronze/sp_load_bronze.sql`](Scripts/bronze/sp_load_bronze.sql). It executes the procedure after creating it.

> **Important:** `init_database.sql` drops the entire `DataWarehouse` database. `init_tables.sql` drops the Bronze tables, and `sp_load_bronze` truncates them before loading. Back up anything important first.

> `BULK INSERT` reads files from the SQL Server host, not necessarily the computer running SSMS. The procedure currently uses hard-coded Windows paths and lowercase ERP filenames; update them for your environment.

## Validation

After loading, check that the tables contain data:

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

## Data Quality and Next Steps

The raw files contain issues for the future Silver layer, including whitespace, blank identifiers, different CRM/ERP key formats, mixed gender values, invalid dates, blank product costs, historical product versions, integer-style sales dates, and possible encoding differences.

### Roadmap

- [x] Create the database, schemas, Bronze tables, and ingestion procedure
- [ ] Add Silver cleansing and standardization
- [ ] Normalize keys and integrate CRM with ERP data
- [ ] Add data-quality checks and rejected-record handling
- [ ] Build Gold facts, dimensions, views, and business metrics
- [ ] Add automated validation, scheduling, and reporting examples

## Project Status

**Bronze ingestion foundation complete.** Silver transformations and Gold analytical models are the next stages.

## License

This project is distributed under the [MIT License](LICENSE).
