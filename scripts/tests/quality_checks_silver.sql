/* Quality Checks in Silver Layer*/

--=======================================================
--Checking silver.crm_cust_info
--=======================================================

--Check for nulls or duplicates in Primary Key

select cst_id,COUNT(*) from silver.crm_cust_info
group by cst_id having count(*)>1 OR cst_id IS NULL;

select cst_key,COUNT(*) from silver.crm_cust_info
group by cst_key having count(*)>1 OR cst_key IS NULL;

--Check for unwanted spaces in String values

select * from silver.crm_cust_info
where cst_firstname ! = TRIM(cst_firstname) or cst_lastname ! = TRIM(cst_lastname);

--Check the consistency of values in low cardinality columns

select distinct cst_marital_status from silver.crm_cust_info;
select distinct cst_gndr from silver.crm_cust_info;

--Check for invalid date orders

select * from silver.crm_cust_info where cst_create_date IS NULL or cst_create_date>GETDATE();

--=======================================================
--Checking silver.crm_prd_info
--=======================================================
--Check for nulls or duplicates in Primary Key

select prd_id,COUNT(*) from silver.crm_prd_info
group by prd_id having count(*)>1 OR prd_id IS NULL;

select prd_key,COUNT(*) from silver.crm_prd_info
group by prd_key having count(*)>1 OR prd_key IS NULL;

--Check for unwanted spaces in String values

select prd_key from silver.crm_prd_info
where prd_key ! = TRIM(prd_key);

select cat_id from silver.crm_prd_info
where cat_id ! = TRIM(cat_id);

select prd_nm from silver.crm_prd_info
where prd_nm ! = TRIM(prd_nm);

--check for Null values or Negative numbers in Numeric columns

select prd_cost from silver.crm_prd_info
where prd_cost IS NULL or prd_cost <0;

--Check the consistency of values in low cardinality columns

select distinct cst_marital_status from silver.crm_cust_info;
select distinct cst_gndr from silver.crm_cust_info;

select distinct prd_line from silver.crm_prd_info;

--Check for invalid date orders

select * from silver.crm_prd_info where prd_start_dt > prd_start_dt;

--=======================================================
--Checking silver.crm_sales_details
--=======================================================

--Check for nulls or duplicates in Primary Key

select * from silver.crm_sales_details;

select sls_cust_id,COUNT(*) from silver.crm_sales_details
group by sls_cust_id having count(*)>1 OR   sls_cust_id IS NULL;


--Check for Nulls or Negative Numbers

select * from silver.crm_sales_details where sls_sales IS NULL or sls_sales<=0;
select * from silver.crm_sales_details where sls_quantity IS NULL or sls_quantity<0;
select * from silver.crm_sales_details where sls_price IS NULL or sls_price<=0;

--Check for unwanted spaces in String values

select sls_ord_num from silver.crm_sales_details
where sls_ord_num ! = TRIM(sls_ord_num);

select sls_prd_key from silver.crm_sales_details
where sls_prd_key ! = TRIM(sls_prd_key);

--Check the consistency of values in low cardinality columns

select distinct prd_line from silver.crm_prd_info;
select distinct cst_gndr from silver.crm_cust_info;

--Check for Invalid Date orders


select * from silver.crm_sales_details
where sls_ship_dt < sls_order_dt OR sls_order_dt > sls_due_dt;

select * from silver.crm_sales_details
where sls_ship_dt > sls_due_dt;

select * from silver.crm_sales_details where sls_ord_num = 'SO69215';

select * from silver.crm_sales_details where sls_prd_key not in 
(select prd_key from silver.crm_prd_info);

select * from silver.crm_sales_details where sls_cust_id not in 
(select sls_cust_id from silver.crm_cust_info);

--check for invalid date values or outliers by validating the boundaries in date ranges

select * from silver.crm_sales_details where sls_order_dt <=0;
select * from silver.crm_sales_details where len(sls_order_dt) < 10 OR len(sls_order_dt)>10;
select * from silver.crm_sales_details where sls_order_dt < 19000101 OR sls_order_dt > 20270101;

select * from silver.crm_sales_details where sls_quantity >1;

--=======================================================
--Checking silver.erp_cust_az12
--=======================================================

select * from silver.erp_cust_az12;

-- Check for Nulls or duplicates in PK

select cid,count(*) from silver.erp_cust_az12
group by cid having count(*) >1 or cid is null;

--Check for unwanted spaces in string values

select * from silver.erp_cust_az12
where cid ! = TRIM(cid);

--CHeck for invalid dates or outliers in date range

select * from silver.erp_cust_az12
where bdate IS NULL or bdate >GETDATE() ;

--CHeck for consistency of data in low cardinality columns

select distinct gen from silver.erp_cust_az12;

select * from silver.crm_cust_info;

select cid from (select (CASE WHEN len(cid) = 13 THEN SUBSTRING(cid,4,len(cid)) 
		 ELSE cid END)as cid from silver.erp_cust_az12) as t1 where cid not in 
(select cst_key from silver.crm_cust_info);

--=======================================================
--Checking silver.erp_loc_a101
--=======================================================

select * from silver.erp_loc_a101;

--CHeck for Nulls or duplicates in PK

select cid,count(*) from silver.erp_loc_a101 
group by cid having count(*)>1 or cid is null;

select * from silver.erp_loc_a101;

--CHeck for Nulls or duplicates in PK

select cid,count(*) from silver.erp_loc_a101 
group by cid having count(*)>1 or cid is null;

select cid from silver.erp_loc_a101 where cid not in 
(select cst_key from silver.crm_cust_info);

--Check for inconsistencies in low cardinality columns

select distinct cntry from silver.erp_loc_a101;

--CHeck for unwanted spaces in String values

select * from silver.erp_loc_a101 where cntry != TRIM(cntry);

