output "redshift_endpoint" {
  value       = aws_redshiftserverless_workgroup.analytics_workgroup.endpoint[0].address
  description = "Redshift Serverless endpoint address"
}

output "lake_formation_registered_bucket" {
  value       = aws_lakeformation_resource.curated_s3_registration.arn
  description = "S3 bucket governed under Lake Formation"
}