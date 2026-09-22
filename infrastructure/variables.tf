variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "demo"
}

variable "curated_bucket_arn" {
  type    = string
  default = "arn:aws:s3:::ismael-ecommerce-processed-065320271591-us-east-1-an"
}


variable "redshift_admin_password" {
  type        = string
  description = "Administrator password for the Redshift Serverless namespace"
  sensitive   = true
}

variable "table_name" {
  type        = string
  description = "Name of the processed Glue catalog table"
  default     = "ismael_ecommerce_processed_065320271591_us_east_1_an"
}