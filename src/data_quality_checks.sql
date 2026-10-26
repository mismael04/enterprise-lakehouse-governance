-- 1. Completeness Test: Check for nulls in critical event attributes
SELECT 
    'Completeness Check' AS test_name,
    COUNT(*) AS failed_record_count
FROM external_finance_schema.ecommerce_events
WHERE event_time IS NULL 
   OR event_type IS NULL 
   OR product_id IS NULL 
   OR user_id IS NULL 
   OR price IS NULL;

-- 2. Validity Test: Ensure no negative prices
SELECT 
    'Validity Check (Negative or Zero Prices)' AS test_name,
    COUNT(*) AS failed_record_count
FROM external_finance_schema.ecommerce_events
WHERE price < 0;

-- 3. Enum Integrity Test: Ensure event_type matches allowed actions
SELECT 
    'Event Type Integrity Check' AS test_name,
    COUNT(*) AS failed_record_count
FROM external_finance_schema.ecommerce_events
WHERE event_type NOT IN ('view', 'cart', 'remove_from_cart', 'purchase');

-- 4. Volume & Uniqueness Check: Total events, distinct users, and distinct sessions
SELECT 
    'Volume & Uniqueness Check' AS test_name,
    COUNT(*) AS total_rows,
    COUNT(DISTINCT user_id) AS unique_users,
    COUNT(DISTINCT user_session) AS unique_sessions
FROM external_finance_schema.ecommerce_events;