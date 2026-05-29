
	/* 
		Loading Transformed Data from Bronze Layer to Silver Layer Tables
		Data from Bronze Layer has been checked for Quality and cleansed or transformed before loading into Silver Layer

	*/
	
	CREATE OR ALTER PROCEDURE silver.load_silver AS
		BEGIN
			DECLARE @batch_start_time DATETIME2, @batch_end_time DATETIME2;
			DECLARE @start_time DATETIME2, @end_time DATETIME2;
			BEGIN TRY
					SET @batch_start_time = GETDATE();
					PRINT '================================================';
					PRINT '>>Loading Silver Layer';
					PRINT '================================================';

					PRINT '------------------------------------------------';
					PRINT '>>Loading CRM Tables';
					PRINT '------------------------------------------------';
					
					-- Loading silver.crm_cust_info
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.crm_cust_info';
					TRUNCATE table silver.crm_cust_info;

					PRINT '>>Inserting Transformed data into: silver.crm_cust_info';
					insert into silver.crm_cust_info(cst_id,cst_key,cst_firstname,cst_lastname,cst_marital_status,cst_gndr,cst_create_date)
					select 
					cst_id,
					cst_key,
					TRIM(cst_firstname) as cst_firstname,
					TRIM(cst_lastname) as cst_lastname,
					(CASE WHEN UPPER(TRIM(cst_marital_status)) = 'S' then 'Single'
							WHEN UPPER(TRIM(cst_marital_status)) = 'M' then 'Married'
							else 'N/A' end) as cst_marital_status,
					(CASE WHEN UPPER(TRIM(cst_gndr)) = 'F' then 'Female' 
							WHEN UPPER(TRIM(cst_gndr)) = 'M' then 'Male' 
							else 'N/A' END) AS cst_gndr,
					cst_create_date 
					from(select *,ROW_NUMBER() OVER(partition by cst_id order by cst_create_date desc) as date_rank
						from bronze.crm_cust_info)t1 
					where date_rank = 1 and cst_id is not null;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time) AS NVARCHAR)+' seconds';


					-- Loading silver.crm_prd_info
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.crm_prd_info';
					TRUNCATE table silver.crm_prd_info;

					PRINT '>>Inserting Transformed data into : silver.crm_prd_info';
					insert into silver.crm_prd_info(prd_id,cat_id,prd_key,prd_nm,prd_cost,prd_line,prd_start_dt,prd_end_dt)
					select 
					prd_id,
					REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
					SUBSTRING(prd_key,7,LEN(prd_key)) as prd_key,
					prd_nm,
					COALESCE(prd_cost,0) as prd_cost,
					--ISNULL(prd_cost,0) as prd_cost,
					(CASE UPPER(TRIM(prd_line))
						 WHEN 'M' THEN 'Mountain'
						 WHEN 'R' THEN 'Road'
						 WHEN 'S' THEN 'Other Sales'
						 WHEN 'T' THEN 'Touring'
						 ELSE 'N/A' END) AS prd_line,
					prd_start_dt,
					(DATEADD(day,-1,LEAD(prd_start_dt) OVER(partition by prd_key order by prd_start_dt asc))) as prd_end_dt
					from bronze.crm_prd_info;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';


					-- Loading silver.crm_sales_details
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.crm_sales_details';
					TRUNCATE table silver.crm_sales_details;

					PRINT '>>Inserting Transformed data into : silver.crm_sales_details';
					insert into silver.crm_sales_details(sls_ord_num,sls_prd_key,sls_cust_id,sls_order_dt,sls_ship_dt,sls_due_dt,sls_sales,sls_quantity,sls_price)
					select 
					sls_ord_num,
					sls_prd_key,
					sls_cust_id,
					(CASE WHEN sls_order_dt = 0 OR len(sls_order_dt) !=8 THEN NULL
					ELSE TRY_CAST(CAST(sls_order_dt AS VARCHAR(8))AS DATE) END) as sls_order_dt,
					sls_ship_dt,
					sls_due_dt,
					--sls_sales as old_sales,
					(CASE WHEN sls_sales IS NULL OR sls_sales <=0 OR sls_sales != sls_quantity* ABS(sls_price)
						 THEN sls_quantity* ABS(sls_price)
						 ELSE sls_sales END) as sls_sales,
					sls_quantity,
					--sls_price,
					(CASE WHEN sls_price = 0 or sls_price is NULL THEN sls_sales/NULLIF(sls_quantity,0)
						  ELSE ABS(sls_price) END) as sls_price
					from bronze.crm_sales_details;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

					PRINT '------------------------------------------------';
					PRINT '>>Loading ERP Tables';
					PRINT '------------------------------------------------';

					-- Loading silver.erp_cust_az12
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.erp_cust_az12';
					TRUNCATE table silver.erp_cust_az12;

					PRINT '>>Inserting Transformed data into : silver.erp_cust_az12';
					insert into silver.erp_cust_az12(cid,bdate,gen)
					select
					(CASE WHEN len(cid) = 13 OR cid like 'NAS%' THEN SUBSTRING(cid,4,len(cid)) 
						 ELSE cid END)as cid,
					(CASE WHEN bdate> GETDATE()  THEN NULL
						 ELSE bdate END) as bdate,
					(CASE WHEN UPPER(TRIM(gen)) IN ('M','Male') THEN 'Male'
						  WHEN UPPER(TRIM(gen)) IN ('F','Female') THEN 'Female' 
						  ELSE 'N/A' END) as gen
					from bronze.erp_cust_az12;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

					-- Loading silver.erp_loc_a101
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.erp_loc_a101';
					TRUNCATE table silver.erp_loc_a101;

					PRINT '>>Inserting Transformed data into : silver.erp_loc_a101';
					insert into silver.erp_loc_a101(cid,cntry)
					select 
					REPLACE(cid,'-','') as cid,
					(CASE WHEN UPPER(TRIM(cntry)) in ('DE') THEN 'Germany' 
						 --WHEN UPPER(TRIM(cntry)) in ('AU','Australia') THEN 'Australia'
						 WHEN UPPER(TRIM(cntry)) in ('US','USA','United States') THEN 'United States'
						 --WHEN UPPER(TRIM(cntry)) in ('UK','United Kingdom') THEN 'United Kingdom'
						 --WHEN UPPER(TRIM(cntry)) in ('CA','Canada') THEN 'Canada'
						 --WHEN UPPER(TRIM(cntry)) in ('FR','FRA','France') THEN 'France'
						 WHEN UPPER(TRIM(cntry)) =''  OR cntry IS NULL THEN 'N/A' 
						 ELSE TRIM(cntry) END) AS cntry
					from bronze.erp_loc_a101;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';
	
					-- Loading silver.erp_px_cat_g1v2
					SET @start_time = GETDATE();
					PRINT '>>Truncate data in silver.erp_px_cat_g1v2'
					TRUNCATE table silver.erp_px_cat_g1v2;

					PRINT '>>Inserting Transformed data into : silver.erp_px_cat_g1v2';
					insert into silver.erp_px_cat_g1v2(id,cat,subcat,maintenance)
					select 
					id,
					cat,
					subcat,
					maintenance
					from bronze.erp_px_cat_g1v2;

					SET @end_time = GETDATE();
					PRINT '>>Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

					SET @batch_end_time = GETDATE();
					PRINT '================================================';
					PRINT '>> Data Insertion/Load into Silver Layer is complete';
					PRINT '>>Overall Load Duration : '+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time)AS NVARCHAR)+' seconds';
					PRINT '================================================';
				END TRY
				BEGIN CATCH
					PRINT '>>Error Occurred';
					PRINT '>>Error Message : '+error_message();
					PRINT '>>Error Number : '+CAST(error_number() as NVARCHAR);
					PRINT '>>Error State : '+CAST(error_state() as NVARCHAR);
				END CATCH
			END
	


