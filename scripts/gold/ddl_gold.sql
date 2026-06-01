/* 
=====================================================================
	DDL Script : Create Gold Layer
	This script creates views for Gold Layer in Data Warehouse.
	These views can be queried directly for Analystics and Reporting.
=====================================================================
*/


--======================================================
--Create Dimension : Customers
--======================================================

IF OBJECT_ID('gold.dim_customers','V') IS NOT NULL
	DROP VIEW gold.dim_customers;
GO

CREATE VIEW gold.dim_customers AS
select
	ROW_NUMBER() OVER(order by ci.cst_id) as customer_key,
	ci.cst_id as customer_id,
	ci.cst_key as customer_number,
	ci.cst_firstname as first_name,
	ci.cst_lastname as last_name,
	la.cntry as country,
	ci.cst_marital_status as marital_status,
	CASE WHEN ci.cst_gndr = 'N/A' THEN COALESCE(ca.gen,'N/A')
		 ELSE ci.cst_gndr END AS gender,
	ca.bdate as birth_date,
	ci.cst_create_date as create_date
from silver.crm_cust_info as ci
LEFT JOIN silver.erp_cust_az12 as ca
on ci.cst_key = ca.cid
LEFT JOIN silver.erp_loc_a101 as la
on ci.cst_key = la.cid;
GO

--======================================================
--Create Dimension : Products
--======================================================

IF OBJECT_ID('gold.dim_products','V') IS NOT NULL
	DROP VIEW gold.dim_products;
GO

CREATE VIEW gold.dim_products AS
select
	ROW_NUMBER() OVER(order by pi.prd_start_dt,pi.prd_key) as product_key,
	pi.prd_id as product_id,
	pi.prd_key as product_number,
	pi.prd_nm as product_name,
	pi.cat_id as category_id,
	pcg.cat as category,
	pcg.subcat as subcategory,
	pcg.maintenance,
	pi.prd_cost as product_cost,
	pi.prd_line as product_line,
	pi.prd_start_dt as start_date
from silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pcg
on pi.cat_id = pcg.id
where prd_end_dt is null;
GO

--======================================================
--Create Fact : Sales
--======================================================

IF OBJECT_ID('gold.fact_sales','V') IS NOT NULL
	DROP VIEW gold.fact_sales;
GO

CREATE VIEW gold.fact_sales as
select 
	sls_ord_num as order_number,
	dp.product_key,
	dc.customer_key,
	sls_order_dt as order_date,
	sls_ship_dt as shipping_date,
	sls_due_dt as due_date,
	sls_sales as sales_amount,
	sls_quantity as quantity,
	sls_price as price
from silver.crm_sales_details sd
left join gold.dim_customers dc
on sd.sls_cust_id = dc.customer_id
left join gold.dim_products dp
on sd.sls_prd_key = dp.product_number;

