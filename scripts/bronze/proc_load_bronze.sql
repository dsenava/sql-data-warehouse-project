/*
================================================================
Stored Procedure : Load Source Data into Bronze Layer
================================================================
*/

--LOAD ALL CSV FILES INTO BRONZE LAYER TABLES--

CREATE OR ALTER PROCEDURE bronze.load_bronze AS
BEGIN
	DECLARE @start_time DATETIME,@end_time DATETIME;
	DECLARE @batch_start_time DATETIME,@batch_end_time DATETIME;
	BEGIN TRY
		PRINT '==============================================';
		PRINT 'Loading Bronze Layer';
		PRINT '==============================================';

		PRINT '----------------------------------------------';
		PRINT 'Loading CRM tables';
		PRINT '----------------------------------------------';

		SET @batch_start_time = GETDATE();
		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.crm_cust_info';
		TRUNCATE TABLE bronze.crm_cust_info;
		PRINT '>>Loading data into : bronze.crm_cust_info';
		BULK INSERT bronze.crm_cust_info
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.crm_prd_info';
		TRUNCATE TABLE bronze.crm_prd_info;
		PRINT '>>Loading data into : bronze.crm_prd_info';
		BULK INSERT bronze.crm_prd_info
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.crm_sales_details';
		TRUNCATE TABLE bronze.crm_sales_details;
		PRINT '>>Loading data into : bronze.crm_sales_details';
		BULK INSERT bronze.crm_sales_details
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		PRINT '----------------------------------------------';
		PRINT 'Loading ERP tables';
		PRINT '----------------------------------------------';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.erp_cust_az12';
		TRUNCATE TABLE bronze.erp_cust_az12;
		PRINT '>>Loading data into : bronze.erp_cust_az12';
		BULK INSERT bronze.erp_cust_az12
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.erp_loc_a101';
		TRUNCATE TABLE bronze.erp_loc_a101;
		PRINT '>>Loading data into : bronze.erp_loc_a101';
		BULK INSERT bronze.erp_loc_a101
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		SET @start_time = GETDATE();
		PRINT '>>Truncating table : bronze.erp_px_cat_g1v2';
		TRUNCATE TABLE bronze.erp_px_cat_g1v2;
		PRINT '>>Loading data into : bronze.erp_px_cat_g1v2';
		BULK INSERT bronze.erp_px_cat_g1v2
		FROM 'C:\Users\deeks\OneDrive\Desktop\DWH Project\DWH\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
		WITH (
			FIRSTROW = 2,
			FIELDTERMINATOR = ',',
			TABLOCK
		);
		SET @end_time = GETDATE();
		PRINT '>> Load Duration : '+CAST(DATEDIFF(second,@start_time,@end_time)AS NVARCHAR)+' seconds';

		PRINT '**********************************';
		SET @batch_end_time = GETDATE();
		PRINT 'Bronze Layer Load complete';
		PRINT '>> Total Load Duration : '+CAST(DATEDIFF(second,@batch_start_time,@batch_end_time) AS NVARCHAR)+' seconds';
	END TRY
	BEGIN CATCH
		PRINT 'Error occurred';
		PRINT 'Error message : '+error_message();
		PRINT 'Error message : '+CAST(error_number() AS NVARCHAR);
		PRINT 'Error message : '+CAST(error_state() as NVARCHAR);
		PRINT 'Error message : '+CAST(error_severity() as NVARCHAR);
	END CATCH
END


--Execute Stored Proc 
EXEC bronze.load_bronze;
