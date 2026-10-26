-- 1. Test the Finance Analyst Persona (Full Unmasked Access)
CREATE EXTERNAL SCHEMA external_finance_schema
FROM DATA CATALOG 
DATABASE 'ecommerce_lake_v2'
IAM_ROLE 'arn:aws:iam::065320271591:role/finance-analyst-execution-role';

-- Should return all columns, including sensitive user_id
SELECT * FROM external_finance_schema.ecommerce_events LIMIT 5;


-- 2. Test the Standard Analyst Persona (Masked PII Access)
CREATE EXTERNAL SCHEMA external_standard_schema
FROM DATA CATALOG 
DATABASE 'ecommerce_lake_v2'
IAM_ROLE 'arn:aws:iam::065320271591:role/redshift-lakeformation-execution-role';

-- Should return all columns EXCEPT user_id (masked by Lake Formation cell filter)
SELECT * FROM external_standard_schema.ecommerce_events LIMIT 5;