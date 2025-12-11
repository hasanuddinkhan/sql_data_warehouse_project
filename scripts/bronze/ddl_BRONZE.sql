/*
=====================================================================
DDL Script: Create Bronze Tables
=====================================================================

Script Purpose:
    This script creates tables in the 'bronze' schema, dropping existing tables
    if they already exist.
    Run this script to re-define the DDL structure of 'bronze' Tables
=====================================================================
*/

-- IF THERE ARE ANY DUPLICATE TABLE AND WE NEED TO REMOVE IT THEN WE WRITE
-- IF OBJECT_ID ('bronze.crm_prd_info','U') is not null
-- DROP TABLE bronze.crm_prd_info;
-- Bronze product information (CRM)
CREATE TABLE bronze.crm_prd_info (
prd_id INT,	
prd_key NVARCHAR(50),	
prd_nm NVARCHAR(50),	
prd_cost INT,	
prd_line NVARCHAR(50),	
prd_start_dt DATETIME,	
prd_end_dt DATETIME
);

-- Bronze Sales Details (CRM)
CREATE TABLE bronze.crm_sls_info(
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

-- Bronze LOC_A101
CREATE TABLE bronze.erp_loc_a101 (
cid NVARCHAR(50),	
cntry NVARCHAR(50)
);

-- Bronze CUST_AZ12
CREATE TABLE bronze.erp_cust_az12(
cid NVARCHAR(50),	
bdate DATE,	
GEN NVARCHAR(50)
);

-- Bronze PX_CAT_G1V2
CREATE TABLE bronze.erp_px_cat_g1v2(
id NVARCHAR(50),	
cat NVARCHAR(50),	
subcat NVARCHAR(50),	
maintenance NVARCHAR(50)
);

-- BRONZE CRM CUST INFO
IF OBJECT_ID ('bronze.crm_cust__info','U') is not null
DROP TABLE bronze.crm_cust_info
CREATE TABLE bronze.crm_cust_info(
cst_id INT,
cst_key NVARCHAR(50),	
cst_firstname NVARCHAR(50),	
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),	
cst_gndr NVARCHAR(50),	
cst_create_date DATE
);
