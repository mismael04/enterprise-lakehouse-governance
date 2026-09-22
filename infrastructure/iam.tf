# 1. Standard Redshift IAM Role
# Used by the standard analytics external schema.
resource "aws_iam_role" "redshift_lakeformation_role" {
  name = "redshift-lakeformation-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "redshift.amazonaws.com",
            "lakeformation.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "redshift_catalog_access" {
  role       = aws_iam_role.redshift_lakeformation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"
}

resource "aws_iam_role_policy_attachment" "redshift_glue_access" {
  role       = aws_iam_role.redshift_lakeformation_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

# Permissions required for Redshift Spectrum to obtain
# Lake Formation-managed data access credentials.
resource "aws_iam_role_policy" "redshift_lakeformation_data_access" {
  name = "redshift-lakeformation-data-access-policy"
  role = aws_iam_role.redshift_lakeformation_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lakeformation:GetDataAccess",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartitions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ismael-ecommerce-processed-065320271591-us-east-1-an",
          "arn:aws:s3:::ismael-ecommerce-processed-065320271591-us-east-1-an/*"
        ]
      }
    ]
  })
}


# 2. Dedicated Finance Analyst IAM Role
# Intended to have full/unmasked access to the curated table.
resource "aws_iam_role" "finance_analyst_role" {
  name = "finance-analyst-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = [
            "redshift.amazonaws.com",
            "lakeformation.amazonaws.com"
          ]
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "finance_catalog_access" {
  role       = aws_iam_role.finance_analyst_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRedshiftAllCommandsFullAccess"
}

resource "aws_iam_role_policy_attachment" "finance_glue_access" {
  role       = aws_iam_role.finance_analyst_role.name
  policy_arn = "arn:aws:iam::aws:policy/AWSGlueConsoleFullAccess"
}

# Permissions required for Redshift Spectrum to obtain
# Lake Formation-managed data access credentials.
resource "aws_iam_role_policy" "finance_lakeformation_data_access" {
  name = "finance-lakeformation-data-access-policy"
  role = aws_iam_role.finance_analyst_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "lakeformation:GetDataAccess",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetPartitions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::ismael-ecommerce-processed-065320271591-us-east-1-an",
          "arn:aws:s3:::ismael-ecommerce-processed-065320271591-us-east-1-an/*"
        ]
      }
    ]
  })
}