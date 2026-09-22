# 1. Register the Curated S3 Bucket with Lake Formation
resource "aws_lakeformation_resource" "curated_s3_registration" {
  arn = var.curated_bucket_arn
}

# 2. Define LF-Tags for Attribute-Based Access Control (TBAC)
resource "aws_lakeformation_lf_tag" "department_tag" {
  key    = "department"
  values = ["analytics", "finance"]
}

resource "aws_lakeformation_lf_tag" "sensitivity_tag" {
  key    = "sensitivity"
  values = ["restricted", "public"]
}

# 3. Associate LF-Tags with the Curated Glue Table
resource "aws_lakeformation_resource_lf_tags" "table_tag_association" {
  table {
    database_name = "ecommerce_data_lake"
    name          = var.table_name
  }

  lf_tag {
    key   = "department"
    value = "analytics"
  }

  lf_tag {
    key   = "sensitivity"
    value = "restricted"
  }

  depends_on = [aws_lakeformation_resource.curated_s3_registration]
}

# 4. Create Data Cells Filter for PII Column-Level Restriction (Exclude customerid for standard analysts)
resource "aws_lakeformation_data_cells_filter" "masked_pii_filter" {
  table_data {
    database_name    = "ecommerce_data_lake"
    name             = "exclude_pii_customer_id_filter_v2"
    table_catalog_id = data.aws_caller_identity.current.account_id
    table_name       = var.table_name

    column_wildcard {
      excluded_column_names = ["customerid"]
    }

    row_filter {
      all_rows_wildcard {}
    }
  }
}

# 5. Lake Formation Permissions for Standard Analytics Role (Database Describe + Filtered Cell-Level SELECT)
resource "aws_lakeformation_permissions" "standard_analyst_database_permissions" {
  principal   = aws_iam_role.redshift_lakeformation_role.arn
  permissions = ["DESCRIBE"]

  database {
    name = "ecommerce_data_lake"
  }
}

resource "aws_lakeformation_permissions" "standard_analyst_table_describe" {
  principal   = aws_iam_role.redshift_lakeformation_role.arn
  permissions = ["DESCRIBE"]

  table {
    database_name = "ecommerce_data_lake"
    name          = var.table_name
  }
}

resource "aws_lakeformation_permissions" "standard_analyst_filtered_select" {
  principal   = aws_iam_role.redshift_lakeformation_role.arn
  permissions = ["SELECT"]

  data_cells_filter {
    table_catalog_id = data.aws_caller_identity.current.account_id
    database_name    = "ecommerce_data_lake"
    table_name       = var.table_name
    name             = aws_lakeformation_data_cells_filter.masked_pii_filter.table_data[0].name
  }

  depends_on = [
    aws_lakeformation_data_cells_filter.masked_pii_filter
  ]
}

# 6. Lake Formation Permissions for Finance Analyst Role (Full unmasked access)
resource "aws_lakeformation_permissions" "finance_analyst_permissions" {
  principal   = aws_iam_role.finance_analyst_role.arn
  permissions = ["ALL"]

  table {
    database_name = "ecommerce_data_lake"
    name          = var.table_name
  }
}