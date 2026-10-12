# Data Catalog

This catalog explains what data lives in the SQL Data Warehouse project and how the tables relate to each other. It is written for business users and analysts who may not be deeply technical, but still need to understand where information is stored and what each field means.

## 1. Project overview

This project follows a Medallion architecture:

- Bronze layer: raw source data loaded from CSV files
- Silver layer: cleaned, standardized, and validated data
- Gold layer: business-ready analytical views for reporting

The data comes from two main sources:

- CRM source data: customer, product, and sales records
- ERP source data: customer demographic, location, and product category reference details

Together, these datasets support customer analysis, product analysis, and sales reporting.

---

## 2. Source system mapping

| Source | Description | Typical information stored |
| --- | --- | --- |
| CRM | Customer relationship data | Customers, products, orders, sales transactions |
| ERP | Enterprise reference data | Customer demographics, countries, product category mapping |

### Source files used

#### CRM files
- `datasets/source_crm/cust_info.csv` — customer master details
- `datasets/source_crm/prd_info.csv` — product catalog details
- `datasets/source_crm/sales_details.csv` — sales transaction records

#### ERP files
- `datasets/source_erp/CUST_AZ12.csv` — ERP customer birthdate and gender
- `datasets/source_erp/LOC_A101.csv` — ERP country/location data
- `datasets/source_erp/PX_CAT_G1V2.csv` — ERP product category and sub-category mapping

---

## 3. Data layer structure

### Bronze layer
The Bronze layer contains raw data copied from the source files without major business logic. This preserves original values for traceability and debugging.

### Silver layer
The Silver layer contains cleaned data with standard column names and normalized values, ready for analytical use.

### Gold layer
The Gold layer contains business-friendly views that combine related tables into a reporting structure for dashboards and analysis.

---

## 4. Bronze tables

### Table: `bronze_crm_cust_info`
Purpose: Raw customer information from CRM.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `cst_id` | `INT` | Unique CRM customer identifier used for tracking customers throughout the warehouse data model. Example: `11000`. |
| `cst_key` | `NVARCHAR(50)` | Business key used to align customer records across CRM and ERP source systems. Example: `AW00011000`. |
| `cst_firstname` | `NVARCHAR(50)` | Customer first name as received in the raw CRM source file. Example: `Jon`. |
| `cst_lastname` | `NVARCHAR(50)` | Customer last name as recorded in the original CRM data. Example: `Yang`. |
| `cst_marital_status` | `NVARCHAR(50)` | Marital status value such as Single, Married, or Divorced in raw CRM data. Example: `M`. |
| `cst_gndr` | `NVARCHAR(50)` | Gender indicator captured in the CRM source for customer profiling. Example: `M`. |
| `cst_create_date` | `DATE` | Date the customer record was created in the CRM system. Example: `2025-10-06`. |

Typical use: customer profile and segmentation.

### Table: `bronze_crm_prd_info`
Purpose: Raw product information from CRM.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `prd_id` | `INT` | Unique product identifier assigned in the CRM source system. Example: `210`. |
| `prd_key` | `NVARCHAR(50)` | Product key used to match product records across source systems and transactions. Example: `CO-RF-FR-R92B-58`. |
| `prd_nm` | `NVARCHAR(50)` | Official product name as stored in the raw CRM product catalog. Example: `HL Road Frame - Black- 58`. |
| `prd_cost` | `INT` | Product cost value used for pricing and profitability analysis. Example: `NULL` or `300`. |
| `prd_line` | `NVARCHAR(50)` | Product family or product line grouping used for category segmentation. Example: `R`. |
| `prd_start_dt` | `DATETIME` | Start date when the product became active or available. Example: `2003-07-01`. |
| `prd_end_dt` | `DATETIME` | End date for historical product versions that are no longer active. Example: `NULL` or `2008-12-27`. |

Typical use: product catalog and historical product lifecycle tracking.

### Table: `bronze_crm_sales_details`
Purpose: Raw sales transactions from CRM.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `sls_ord_num` | `NVARCHAR(50)` | Unique sales order number identifying each customer order line. Example: `SO43697`. |
| `sls_prd_key` | `NVARCHAR(50)` | Product key associated with the sold item in the sales transaction. Example: `BK-R93R-62`. |
| `sls_cust_id` | `INT` | Customer identifier linked to the transaction for customer-level analysis. Example: `21768`. |
| `sls_order_dt` | `INT` | Order date stored in transactional numeric format before conversion. Example: `20101229`. |
| `sls_ship_dt` | `INT` | Shipping date used to plan logistics and fulfillment tracking. Example: `20110105`. |
| `sls_due_dt` | `INT` | Due date associated with the sales order for delivery planning. Example: `20110110`. |
| `sls_sales` | `INT` | Revenue value generated from the sales order line item. Example: `3578`. |
| `sls_quantity` | `INT` | Number of units sold for the order line item. Example: `1`. |
| `sls_price` | `INT` | Unit price charged for each item sold in the transaction. Example: `3578`. |

Typical use: order-level sales analysis and revenue reporting.

### Table: `bronze_erp_cust_az12`
Purpose: Raw ERP customer demographic details.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `CID` | `NVARCHAR(50)` | Customer identifier used to join ERP demographic data with CRM customer records. Example: `NASAW00011000`. |
| `BDATE` | `DATE` | Customer birthdate used for age-related demographic analysis. Example: `1971-10-06`. |
| `GEN` | `NVARCHAR(50)` | Gender value supplied by the ERP source for demographic enrichment. Example: `Male`. |

Typical use: customer traits and demographic enrichment.

### Table: `bronze_erp_loc_a101`
Purpose: Raw ERP customer location mapping.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `CID` | `NVARCHAR(50)` | Customer identifier used to connect location data with customer profiles. Example: `AW-00011000`. |
| `CNTRY` | `NVARCHAR(50)` | Country name associated with the customer for geographic analysis. Example: `Australia`. |

Typical use: customer geography and country-based reporting.

### Table: `bronze_erp_px_cat_g1v2`
Purpose: Raw ERP product category reference records.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `ID` | `NVARCHAR(50)` | Reference key used to map product categories and organization metadata. Example: `AC_BR`. |
| `CAT` | `NVARCHAR(50)` | Main product category used for grouping and category-based reporting. Example: `Accessories`. |
| `SUBCAT` | `NVARCHAR(50)` | Sub-category used to classify products within a broader category. Example: `Bike Racks`. |
| `MAINTENANCE` | `NVARCHAR(50)` | Maintenance indicator used to identify category-specific operational requirements. Example: `Yes`. |

Typical use: product grouping and category segmentation.

---

## 5. Silver tables

The Silver layer is the cleaned and standardized version of the Bronze data. It keeps the same business meaning, but with better consistency and ready-to-use dates and fields.

### Table: `silver_crm_cust_info`
Purpose: Cleaned CRM customer table.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `cst_id` | `INT` | Unique customer identifier used in CRM and downstream reporting across warehouse datasets. Example: `11000`. |
| `cst_key` | `NVARCHAR(50)` | Business key used to match customer records consistently between CRM and ERP sources. Example: `AW00011000`. |
| `cst_firstname` | `NVARCHAR(50)` | Cleaned first name prepared for customer profiling and reporting use cases. Example: `Jon`. |
| `cst_lastname` | `NVARCHAR(50)` | Cleaned last name standardized for customer identity and segmentation tasks. Example: `Yang`. |
| `cst_marital_status` | `NVARCHAR(50)` | Standardized marital status value used for customer demographic segmentation. Example: `M`. |
| `cst_gndr` | `NVARCHAR(50)` | Standardized gender value used in customer analysis and demographic reporting. Example: `M`. |
| `cst_create_date` | `DATE` | Date the customer record was created in the source CRM system. Example: `2025-10-06`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking when the record was loaded into the warehouse. Example: `2025-10-12 10:30:00`. |

Typical use: customer master data for reporting and segmentation.

### Table: `silver_crm_prd_info`
Purpose: Cleaned product master table.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `prd_id` | `INT` | Unique product identifier used to distinguish products within the warehouse. Example: `210`. |
| `prd_key` | `NVARCHAR(50)` | Product reference key used for linking product data to transactions and joins. Example: `CO-RF-FR-R92B-58`. |
| `cat_id` | `NVARCHAR(50)` | Category identifier linking the product to its ERP category metadata. Example: `AC_BR`. |
| `prd_nm` | `NVARCHAR(50)` | Standardized product name prepared for product and sales reporting. Example: `HL Road Frame - Black- 58`. |
| `prd_cost` | `INT` | Product cost value used for pricing analysis and profitability evaluation. Example: `300`. |
| `prd_line` | `NVARCHAR(50)` | Product family or line grouping used for broader product categorization. Example: `R`. |
| `prd_start_dt` | `DATE` | Date when the product became active in the product lifecycle. Example: `2003-07-01`. |
| `prd_end_dt` | `DATE` | End date for historical product versions no longer considered active. Example: `NULL`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking when the product record entered the warehouse. Example: `2025-10-12 10:31:00`. |

Typical use: product analysis and active-product reporting.

### Table: `silver_crm_sales_details`
Purpose: Cleaned sales transaction table.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `sls_ord_num` | `NVARCHAR(50)` | Unique sales order number identifying each customer order line item. Example: `SO43697`. |
| `sls_prd_key` | `NVARCHAR(50)` | Product key identifying the item sold in the transaction. Example: `BK-R93R-62`. |
| `sls_cust_id` | `INT` | Customer identifier linking the transaction to the customer dimension. Example: `21768`. |
| `sls_order_dt` | `DATE` | Date when the order was placed and ready for sales analysis. Example: `2010-12-29`. |
| `sls_ship_dt` | `DATE` | Date when the order was shipped to the customer. Example: `2011-01-05`. |
| `sls_due_dt` | `DATE` | Due date associated with the sales order for fulfillment tracking. Example: `2011-01-10`. |
| `sls_sales` | `INT` | Revenue amount generated by the sales order line item. Example: `3578`. |
| `sls_quantity` | `INT` | Number of units sold in the transaction row. Example: `1`. |
| `sls_price` | `INT` | Unit price charged for each item in the transaction. Example: `3578`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking the record creation in the warehouse. Example: `2025-10-12 10:32:00`. |

Typical use: sales reporting, revenue analysis, and order trends.

### Table: `silver_erp_cust_az12`
Purpose: Cleaned ERP customer demographic table.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `CID` | `NVARCHAR(50)` | Customer identifier used to enrich CRM customer data with ERP demographics. Example: `NASAW00011000`. |
| `BDATE` | `DATE` | Customer birthdate used for age and demographic analysis. Example: `1971-10-06`. |
| `GEN` | `NVARCHAR(50)` | Gender value obtained from ERP for demographic enrichment and profiling. Example: `Male`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking when the ERP customer record was loaded. Example: `2025-10-12 10:33:00`. |

Typical use: enrich customer profile with demographic attributes.

### Table: `silver_erp_loc_a101`
Purpose: Cleaned ERP country/location mapping.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `CID` | `NVARCHAR(50)` | Customer identifier used to connect location records with customer data. Example: `AW-00011000`. |
| `CNTRY` | `NVARCHAR(50)` | Country name assigned to the customer for regional and market analysis. Example: `Australia`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking when the location record was loaded into warehouse. Example: `2025-10-12 10:34:00`. |

Typical use: customer location analysis and market segmentation.

### Table: `silver_erp_px_cat_g1v2`
Purpose: Cleaned ERP product category metadata.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `ID` | `NVARCHAR(50)` | Category reference key used to map product classifications across datasets. Example: `AC_BR`. |
| `CAT` | `NVARCHAR(50)` | Main product category used for category-based business reporting. Example: `Accessories`. |
| `SUBCAT` | `NVARCHAR(50)` | Sub-category providing a more detailed product grouping level. Example: `Bike Racks`. |
| `MAINTENANCE` | `NVARCHAR(50)` | Maintenance indicator used to flag category-specific operational requirements. Example: `Yes`. |
| `dwh_create_date` | `DATETIME` | Timestamp marking when the ERP category metadata was loaded. Example: `2025-10-12 10:35:00`. |

Typical use: product taxonomy and grouping for reporting.

---

## 6. Gold views

The Gold layer creates business-friendly analytics objects used for dashboards and reporting.

### View: `gold.dim_customer`
Purpose: Customer dimension used for reporting and analysis.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `customer_key` | `INT` | Surrogate key created to uniquely identify each customer across reporting and analytical joins. |
| `customer_id` | `INT` | Customer identifier originating from CRM for customer-level business reporting. |
| `customer_number` | `NVARCHAR(50)` | Business customer number used by the source system for customer cross-reference. |
| `first_name` | `NVARCHAR(50)` | Customer first name prepared for demographic and segmentation analysis. |
| `last_name` | `NVARCHAR(50)` | Customer last name used in customer profiling and reporting views. |
| `marital_status` | `NVARCHAR(50)` | Customer marital status used for demographic and segmentation analysis. |
| `gender` | `NVARCHAR(50)` | Customer gender selected from CRM, with ERP value as fallback when CRM data missing. |
| `birthdate` | `DATE` | Customer birthdate used for age and demographic customer analysis. |
| `country` | `NVARCHAR(50)` | Customer country used for regional and geographic reporting. |
| `created_date` | `DATE` | Date the customer record was created in the source system. |

Typical use: customer dimension in BI tools, segmentation, customer profiling, and demographic analysis.

### View: `gold.dim_products`
Purpose: Product dimension with current active products only.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `product_key` | `INT` | Surrogate key generated to uniquely identify each active product in the dimension. |
| `product_id` | `INT` | Product identifier from CRM used for product-level analysis and joins. |
| `product_number` | `NVARCHAR(50)` | Product reference number used as the primary business key for matching records. |
| `product_name` | `NVARCHAR(50)` | Product name displayed in reports and used for business analysis. |
| `product_cost` | `INT` | Cost value of the product used in profitability and pricing analysis. |
| `category_id` | `NVARCHAR(50)` | Category identifier linking the product to its ERP product category mapping. |
| `category` | `NVARCHAR(50)` | Main product category used for category-based reporting and analysis. |
| `sub_category` | `NVARCHAR(50)` | Product sub-category used for more detailed product segmentation and grouping. |
| `MAINTENANCE` | `NVARCHAR(50)` | Maintenance indicator identifying category-specific operational or maintenance needs. |
| `product_line` | `NVARCHAR(50)` | Product line or family grouping used in portfolio and lifecycle analysis. |
| `start_date` | `DATETIME` | Date the product became active or available for sale. |

Note: Only rows where `prd_end_dt IS NULL` are included, so this view reflects the current product state rather than historical versions.

Typical use: product reporting, category analysis, and product-level dashboarding.

### View: `gold.fact_sales`
Purpose: Sales fact table for performance and revenue reporting.

| Column | Data Type | Meaning |
| --- | --- | --- |
| `order_number` | `NVARCHAR(50)` | Sales order number identifying the order line used in sales reporting. |
| `product_key` | `INT` | Product dimension key linking sales records to product master data. |
| `customer_key` | `INT` | Customer dimension key linking sales records to customer profile data. |
| `order_date` | `DATE` | Date when the sales order was placed for trend and performance analysis. |
| `shipping_date` | `DATE` | Date when the order was shipped and fulfilled to the customer. |
| `due_date` | `DATE` | Due date associated with the order for delivery and fulfillment tracking. |
| `sales_amount` | `INT` | Total sales value generated by the transaction for revenue analysis. |
| `quantity` | `INT` | Quantity sold used for volume, trend, and demand analysis. |
| `price` | `INT` | Unit selling price charged for each item in the transaction. |

Typical use: sales analysis, revenue trend reporting, and fact-based KPI dashboards.

---

## 7. Relationships between tables

Understanding how the tables connect is essential:

- `silver_crm_cust_info.cst_key` maps to `silver_erp_cust_az12.CID`
- `silver_crm_cust_info.cst_key` maps to `silver_erp_loc_a101.CID`
- `silver_crm_prd_info.cat_id` maps to `silver_erp_px_cat_g1v2.ID`
- `silver_crm_sales_details.sls_prd_key` joins to `gold.dim_products.product_number`
- `silver_crm_sales_details.sls_cust_id` joins to `gold.dim_customer.customer_id`

This creates the star-schema pattern:

- Dimension tables: customer and product
- Fact table: sales transactions

---

## 8. Business interpretation examples

### Example: customer profile
A user may want to know which customers are male or female, where they live, and when they were created. This information is available in `gold.dim_customer`.

### Example: product catalog
A user may want to know all current product names, their categories, and active product lines. This is available in `gold.dim_products`.

### Example: sales performance
A user may want to measure revenue by customer, product, or date range. This is available in `gold.fact_sales`.

---

## 9. Data quality notes

- Bronze is the raw and unvalidated layer.
- Silver is where standardization and cleaning are applied.
- Gold is intended for business consumption and reporting.
- Product history is tracked using `prd_start_dt` and `prd_end_dt`; the Gold view keeps only active products.
- `dwh_create_date` tells when data was loaded into the warehouse for auditing.

---

## 10. Recommended usage

For most business users, start with the Gold views:

- Use `gold.dim_customer` for customer reporting
- Use `gold.dim_products` for product and category analysis
- Use `gold.fact_sales` for sales and revenue reporting

Use Bronze and Silver tables when you need to inspect raw values, troubleshoot data quality issues, or trace where a value came from.

---

## 11. Quick reference

| Layer | Purpose | Best for |
| --- | --- | --- |
| Bronze | Raw source data | Audit, traceability, debugging |
| Silver | Cleaned and standardized data | Data validation, transformation logic |
| Gold | Business-ready analytics layer | Dashboards, reports, analytics |

This catalog is meant to help non-technical users understand where the information lives and how it can be used for reporting and analysis.
