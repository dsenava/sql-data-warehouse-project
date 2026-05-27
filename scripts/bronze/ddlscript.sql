/*
===============================================================
DDL Script : Create Tables in Bronze Layer to load source data
===============================================================
*/

--create tables for data from CRM --

IF OBJECT_ID ('bronze.crm_cust_info','U') IS NOT NULL
	DROP table bronze.crm_cust_info;
create table bronze.crm_cust_info(
cst_id int,
cst_key NVARCHAR(50),
cst_firstname NVARCHAR(50),
cst_lastname NVARCHAR(50),
cst_marital_status NVARCHAR(50),
cst_gndr NVARCHAR(50),
cst_create_date DATE
);

IF OBJECT_ID ('bronze.crm_prd_info','U') IS NOT NULL
	DROP table bronze.crm_prd_info;
create table bronze.crm_prd_info(
prd_id int,
prd_key NVARCHAR(50),
prd_nm NVARCHAR(50),
prd_cost NVARCHAR(50),
prd_line NVARCHAR(50),
prd_start_dt DATE,
prd_end_dt DATE
);

IF OBJECT_ID ('bronze.crm_sales_details','U') IS NOT NULL
	DROP table bronze.crm_sales_details;
create table bronze.crm_sales_details(
sls_ord_num NVARCHAR(50),
sls_prd_key NVARCHAR(50),
sls_cust_id NVARCHAR(50),
sls_order_dt int,
sls_ship_dt DATE,
sls_due_dt DATE,
sls_sales int,
sls_quantity int,
sls_price int
);

--create tables for data from ERP --

IF OBJECT_ID ('bronze.erp_cust_az12','U') IS NOT NULL
	DROP table bronze.erp_cust_az12;
create table bronze.erp_cust_az12(
CID NVARCHAR(50),
BDATE DATE,
GEN NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_loc_a101','U') IS NOT NULL
	DROP table bronze.erp_loc_a101;
create table bronze.erp_loc_a101(
CID NVARCHAR(50),
CNTRY NVARCHAR(50)
);

IF OBJECT_ID ('bronze.erp_px_cat_g1v2','U') IS NOT NULL
	DROP table bronze.erp_px_cat_g1v2;
create table bronze.erp_px_cat_g1v2(
ID NVARCHAR(50),
CAT NVARCHAR(50),
SUBCAT NVARCHAR(50),
MAINTENANCE NVARCHAR(50)
);
