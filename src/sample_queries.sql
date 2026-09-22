-- 1. Create an external schema in Redshift mapping directly to your Lake Formation Glue Data Catalog
CREATE EXTERNAL SCHEMA IF NOT EXISTS external_ecommerce
FROM DATA CATALOG
DATABASE 'ecommerce_data_lake'
IAM_ROLE 'arn:aws:iam::065320271591:role/redshift-lakeformation-execution-role'
REGION 'us-east-1';

-- 2. High-performance analytical query verifying processed Parquet files with Lake Formation PII enforcement
SELECT 
    country,
    COUNT(DISTINCT invoiceno) AS total_orders,
    SUM(quantity * unitprice) AS total_revenue
FROM external_ecommerce."ismael_ecommerce_processed_065320271591_us_east_1_an"
GROUP BY 1
HAVING SUM(quantity * unitprice) IS NOT NULL
ORDER BY total_revenue DESC
LIMIT 10;