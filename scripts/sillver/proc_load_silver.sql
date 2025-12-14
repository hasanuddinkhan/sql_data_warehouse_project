/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
		
Parameters:
    None. 
	  This stored procedure does not accept any parameters or return any values.

Usage Example:
    EXEC Silver.load_silver;
===============================================================================
*/

-- Creating a stored procedure
CREATE OR ALTER	PROCEDURE silver.load_silver
AS BEGIN
		DECLARE @start_time DATETIME, @end_time DATETIME, @batch_start_time DATETIME, @batch_end_time DATETIME;
		BEGIN TRY
					SET @batch_start_time=GETDATE();
					PRINT '--------------------------------------------------------------';
					PRINT 'LOADING SILVER LAYER';
					PRINT '--------------------------------------------------------------';
	
					--Inserting the silver.crm_cust_info data
					PRINT '==================================================================='
					PRINT 'LOADING CRM INFO'
					PRINT '==================================================================='
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.crm_cust_info'
					TRUNCATE TABLE silver.crm_cust_info;
					PRINT '>>Inserting Data Into: silver.crm_cust_info'
							INSERT INTO silver.crm_cust_info (
								cst_id, 
								cst_key, 
								cst_firstname, 
								cst_lastname, 
								cst_marital_status, 
								cst_gndr,
								cst_create_date
							)
							SELECT
								cst_id,
								cst_key,
								TRIM(cst_firstname) AS cst_firstname,
								TRIM(cst_lastname) AS cst_lastname,
								CASE 
									WHEN UPPER(TRIM(cst_marital_status)) = 'S' THEN 'Single'
									WHEN UPPER(TRIM(cst_marital_status)) = 'M' THEN 'Married'
									ELSE 'n/a'
								END AS cst_marital_status, -- Normalize marital status values to readable format
								CASE 
									WHEN UPPER(TRIM(cst_gndr)) = 'F' THEN 'Female'
									WHEN UPPER(TRIM(cst_gndr)) = 'M' THEN 'Male'
									ELSE 'n/a'
								END AS cst_gndr, -- Normalize gender values to readable format
								cst_create_date
							FROM (
								SELECT
									*,
									ROW_NUMBER() OVER (PARTITION BY cst_id ORDER BY cst_create_date DESC) AS flag_last
								FROM bronze.crm_cust_info
								WHERE cst_id IS NOT NULL
							) t
							WHERE flag_last = 1; -- Select the most recent record per customer
					SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'


-- Inserting the data into the silver.crm_prd_info
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.crm_prd_info'
					TRUNCATE TABLE silver.crm_prd_info;
					PRINT '>>Inserting Data Into: silver.crm_prd_info'
					INSERT INTO silver.crm_prd_info(
						prd_id,
						cat_id,
						prd_key,
						prd_nm,
						prd_cost,
						prd_line,
						prd_start_dt,
						prd_end_dt
					)

					Select
						prd_id,
						REPLACE(SUBSTRING(prd_key,1,5),'-','_') as cat_id,
						SUBSTRING(prd_key, 7, LEN(prd_key)) as prd_key,
						prd_nm,
						ISNULL(prd_cost,0) AS prd_cost,
						CASE UPPER(TRIM(prd_line))
							 WHEN 'M' then 'Mountain'
							 WHEN 'R' then 'Road'
							 WHEN 'S' then 'Other Sales'
							 WHEN 'T' then 'Touring'
						else 'n/a'
						END AS prd_line,
						CAST(prd_start_dt AS DATE) AS prd_start_dt,
						CAST(LEAD(prd_start_dt) OVER (PARTITION BY prd_key order by prd_start_dt) - 1 AS DATE) as prd_end_dt
					from bronze.crm_prd_info
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'



					-- Inserting silver.crm_sls_info
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.crm_sls_info'
					TRUNCATE TABLE silver.crm_sls_info;
					PRINT '>>Inserting Data Into: silver.crm_sls_info'
					INSERT INTO silver.crm_sls_info(
								sls_ord_num,
								sls_prd_key,
								sls_cust_id,
								sls_order_dt,
								sls_ship_dt,
								sls_due_dt,
								sls_sales,
								sls_quantity,
								sls_price
					)

						SELECT 
								sls_ord_num,
								sls_prd_key,
								sls_cust_id,
								CASE 
									WHEN sls_order_dt = 0 OR LEN(sls_order_dt) != 8 THEN NULL
									ELSE CAST(CAST(sls_order_dt AS VARCHAR) AS DATE)
								END AS sls_order_dt,
								CASE 
									WHEN sls_ship_dt = 0 OR LEN(sls_ship_dt) != 8 THEN NULL
									ELSE CAST(CAST(sls_ship_dt AS VARCHAR) AS DATE)
								END AS sls_ship_dt,
								CASE 
									WHEN sls_due_dt = 0 OR LEN(sls_due_dt) != 8 THEN NULL
									ELSE CAST(CAST(sls_due_dt AS VARCHAR) AS DATE)
								END AS sls_due_dt,
								CASE 
									WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales != sls_quantity * ABS(sls_price) 
										THEN sls_quantity * ABS(sls_price)
									ELSE sls_sales
								END AS sls_sales, -- Recalculate sales if original value is missing or incorrect
								sls_quantity,
								CASE 
									WHEN sls_price IS NULL OR sls_price <= 0 
										THEN sls_sales / NULLIF(sls_quantity, 0)
									ELSE sls_price  -- Derive price if original value is invalid
								END AS sls_price
							FROM bronze.crm_sls_info
				SET @end_time=GETDATE();
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------'





					PRINT '===================================================================';
					PRINT 'LOADING ERP INFO';
					PRINT '===================================================================';


					-- Inserting the data into silver.erp_cust_az12
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.erp_cust_az12'
					TRUNCATE TABLE silver.erp_cust_az12;
					PRINT '>>Inserting Data Into: silver.erp_cust_az12'
					INSERT INTO silver.erp_cust_az12 (cid,bdate,gen)
					select 
							CASE WHEN cid LIKE 'NAS%' THEN SUBSTRING(cid,4,LEN(cid))  -- Handled invalid values 'NAS'
								 ELSE cid
							END AS cid,
					CASE WHEN bdate > GETDATE() THEN NULL
						 ELSE bdate		-- Set future birthdate to null
					END AS bdate,
					CASE WHEN UPPER(TRIM(gen)) in ('F', 'FEMALE') THEN 'Female'
						 WHEN UPPER(TRIM(gen)) in ('M', 'MALE') THEN 'Male'
						 ELSE 'n/a'			-- Normalize gender values and handle unknown cases
					END AS gen
					from bronze.erp_cust_az12
					SET @end_time=GETDATE();
					PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
					PRINT '-------------'



					-- Inserting the data into silver.erp_loc_a101 
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.erp_loc_a101'
					TRUNCATE TABLE silver.erp_loc_a101;
					PRINT '>>Inserting Data Into: silver.erp_loc_a101'
					insert into silver.erp_loc_a101 (cid,cntry)
					Select 
					REPLACE(cid,'-','') as cid,
					CASE WHEN TRIM (cntry) = 'DE' THEN 'Germany'
						 WHEN TRIM (cntry) IN ('US', 'USA') THEN 'United States'
						 WHEN TRIM (cntry) = '' or cntry is null THEN 'n/a'
						 ELSE TRIM(cntry)
						 END as cntry
					from bronze.erp_loc_a101
					SET @end_time=GETDATE();
					PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
					PRINT '-------------'



					-- Inserting the data into silver.erp_px_cat_g1v2
					SET @start_time=GETDATE();
					PRINT '>>Truncating table: silver.erp_px_cat_g1v2'
					TRUNCATE TABLE silver.erp_px_cat_g1v2;
					PRINT '>>Inserting Data Into: silver.erp_px_cat_g1v2'
					INSERT INTO silver.erp_px_cat_g1v2(
					id,
					cat,
					subcat,
					maintenance
					)

					Select 
					id,
					cat,
					subcat,
					maintenance
					from bronze.erp_px_cat_g1v2
					SET @end_time=GETDATE();
					PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
					PRINT '-------------'
					SET @batch_end_time=GETDATE();
				PRINT '-------------++++++++++++++++------------------'
				PRINT 'LOADING SILVER LAYER IS COMPLETED'
				PRINT '>> LOAD DURATION:' + CAST (DATEDIFF(second, @start_time, @end_time) AS NVARCHAR) + ' seconds';
				PRINT '-------------++++++++++++++++------------------'
			
					END TRY
					BEGIN CATCH
				PRINT '==================================='
				PRINT 'ERROR OCCURED LOADING SILVER LAYER'
				PRINT '==================================='
			END CATCH
			END
