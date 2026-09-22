# Dedicated S3 bucket for immutable CloudTrail security and governance audit logs
resource "aws_s3_bucket" "audit_logs" {
  bucket        = "ismael-lakehouse-audit-logs-${data.aws_caller_identity.current.account_id}"
  force_destroy = true
}

# Block public access to the audit bucket
resource "aws_s3_bucket_public_access_block" "audit_public_access" {
  bucket                  = aws_s3_bucket.audit_logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable server-side encryption for compliance
resource "aws_s3_bucket_server_side_encryption_configuration" "audit_encryption" {
  bucket = aws_s3_bucket.audit_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "audit_ownership" {
  bucket = aws_s3_bucket.audit_logs.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_acl" "audit_acl" {
  depends_on = [
    aws_s3_bucket_ownership_controls.audit_ownership,
    aws_s3_bucket_public_access_block.audit_public_access
  ]
  bucket = aws_s3_bucket.audit_logs.id
  acl    = "private"
}

# Secure Bucket Policy required by CloudTrail
resource "aws_s3_bucket_policy" "audit_policy" {
  bucket = aws_s3_bucket.audit_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AWSCloudTrailAclCheck"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:GetBucketAcl"
        Resource  = aws_s3_bucket.audit_logs.arn
      },
      {
        Sid       = "AWSCloudTrailWrite"
        Effect    = "Allow"
        Principal = { Service = "cloudtrail.amazonaws.com" }
        Action    = "s3:PutObject"
        Resource  = "${aws_s3_bucket.audit_logs.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}

# CloudTrail Trail capturing governance, lakehouse access, and security changes
resource "aws_cloudtrail" "lakehouse_audit_trail" {
  name                          = "enterprise-lakehouse-audit-trail"
  s3_bucket_name                = aws_s3_bucket.audit_logs.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_logging                = true
  enable_log_file_validation    = true

  depends_on = [aws_s3_bucket_policy.audit_policy]
}