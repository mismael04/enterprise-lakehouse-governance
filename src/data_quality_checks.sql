-- 1. Completeness Test: Check for nulls or missing critical attributes
SELECT 
    'Completeness Check' AS test_name,
    COUNT(*) AS failed_record_count
FROM external_ecommerce."ismael_ecommerce_processed_065320271591_us_east_1_an"
WHERE invoiceno IS NULL 
   OR stockcode IS NULL 
   OR quantity IS NULL 
   OR unitprice IS NULL;

-- 2. Validity Test: Ensure no negative or zero quantities/prices
SELECT 
    'Validity Check (Negative Quantities or Prices)' AS test_name,
    COUNT(*) AS failed_record_count
FROM external_ecommerce."ismael_ecommerce_processed_065320271591_us_east_1_an"
WHERE quantity <= 0 
   OR unitprice < 0;

-- 3. Business Rule Integrity Test: Flag anomalies where calculated revenue is negative
SELECT 
    'Business Integrity Check' AS test_name,
    MIN(quantity * unitprice) AS minimum_calculated_revenue
FROM external_ecommerce."ismael_ecommerce_processed_065320271591_us_east_1_an";

-- 4. Volume & Uniqueness Check: Total row count and distinct invoice check
SELECT 
    'Volume & Uniqueness Check' AS test_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT invoiceno) AS unique_invoices
FROM external_ecommerce."ismael_ecommerce_processed_065320271591_us_east_1_an";