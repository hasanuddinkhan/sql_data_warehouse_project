/*
=====================================================================
Stored Procedure: Load Bronze Layer (Source -> Bronze)
=====================================================================

Script Purpose:
    This stored procedure loads data into the 'bronze' schema from external CSV files.
    It performs the following actions:
    - Truncates the bronze tables before loading data.
    - Uses the `BULK INSERT` command to load data from csv Files to bronze tables.

Parameters:
    None.
    This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC bronze.load_bronze;
=====================================================================
*/

CREATE OR ALTER PROCEDURE bronze.load_bronze AS 
BEGIN
	DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
			BEGIN TRY
					SET @batch_start_time=GETDATE();
					PRINT '--------------------------------------------------------------';
					PRINT 'LOADING BRONZE LAYER';
					PRINT '--------------------------------------------------------------';
				-- BULK INSERTING THE DATA FIRST TABLE
				PRINT '==================================================================='
				PRINT 'LOADING CRM INFO'
				PRINT '==================================================================='
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.crm_cust_info'
				TRUNCATE TABLE bronze.crm_cust_info;
				PRINT '>> INSERTING DATA INTO: bronze.crm_cust_info'
				BULK INSERT bronze.crm_cust_info
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
					SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'

				-- BULK INSERTING THE DATA PRD INFO
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.crm_prd_info'
				TRUNCATE TABLE bronze.crm_prd_info;
				PRINT '>> INSERTING DATA INTO: bronze.crm_prd_info'
				BULK INSERT bronze.crm_prd_info
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'


				-- BULK INSERTING THE DATA SLS INFO
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.crm_sls_info'
				TRUNCATE TABLE bronze.crm_sls_info;
				PRINT '>> INSERTING DATA INTO: bronze.crm_sls_info'
				BULK INSERT bronze.crm_sls_info
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'

				-- BULK INSERTING THE DATA CUST_AZ12 INFO
				PRINT '===================================================================';
				PRINT 'LOADING ERP INFO';
				PRINT '===================================================================';
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.erp_cust_az12'
				TRUNCATE TABLE bronze.erp_cust_az12;
				PRINT '>> INSERTING DATA INTO: bronze.erp_cust_az12'
				BULK INSERT bronze.erp_cust_az12
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'


				-- BULK INSERTING THE DATA LOC_A101 INFO
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.erp_loc_a101'
				TRUNCATE TABLE bronze.erp_loc_a101;
				PRINT '>> INSERTING DATA INTO: bronze.erp_loc_a101'
				BULK INSERT bronze.erp_loc_a101
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'


				-- BULK INSERTING THE DATA PX_CAT_G1V2 INFO
				SET @start_time=GETDATE();
				PRINT '>> TRUNCATING TABLE: bronze.erp_cat_g1v2'
				TRUNCATE TABLE bronze.erp_px_cat_g1v2;
				PRINT '>> INSERTING DATA INTO: bronze.erp_cat_g1v2'
				BULK INSERT bronze.erp_px_cat_g1v2
				FROM 'F:\My Datawarehouse Project\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
				WITH (
						FIRSTROW = 2,
						FIELDTERMINATOR = ',',
						TABLOCK
					);
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'
			SET @batch_end_time=GETDATE();
				PRINT '-------------++++++++++++++++------------------'
				PRINT 'LOADING BRONZE LAYER IS COMPLETED'
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------++++++++++++++++------------------'
			
			END TRY
			BEGIN CATCH
				PRINT '==================================='
				PRINT 'ERROR OCCURED LOADING BRONZE LAYER'
				PRINT '==================================='
			END CATCH
END
