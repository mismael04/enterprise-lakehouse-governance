# Default VPC, Subnet, and Security Group lookups for serverless deployment
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  vpc_id = data.aws_vpc.default.id
  name   = "default"
}

# Redshift Serverless Namespace
resource "aws_redshiftserverless_namespace" "analytics_namespace" {
  namespace_name       = "enterprise-analytics-namespace"
  db_name              = "ecommerce_warehouse"
  admin_username       = "adminuser"
  admin_user_password  = var.redshift_admin_password
  default_iam_role_arn = aws_iam_role.redshift_lakeformation_role.arn

  iam_roles = [
    aws_iam_role.redshift_lakeformation_role.arn,
    aws_iam_role.finance_analyst_role.arn
  ]
}

# Redshift Serverless Workgroup
resource "aws_redshiftserverless_workgroup" "analytics_workgroup" {
  workgroup_name = "enterprise-analytics-workgroup"
  namespace_name = aws_redshiftserverless_namespace.analytics_namespace.namespace_name
  base_capacity  = 8

  subnet_ids          = data.aws_subnets.default.ids
  security_group_ids  = [data.aws_security_group.default.id]
  
  # Portfolio/demo configuration
  # Production deployments should use private networking and controlled ingress.
  publicly_accessible = true
}