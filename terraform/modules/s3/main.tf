# -----------------------------------------------------------------------------
# S3 MODULE: The Dedicated Storage Array
# -----------------------------------------------------------------------------

# 1. Data source for AWS Caller Identity
# Used to inject the Account ID into the bucket name for global uniqueness.
data "aws_caller_identity" "current" {}

# 2. Dynamically creates S3 buckets
resource "aws_s3_bucket" "app_storage" {
  # for_each creates one bucket resource for every item in var.bucket_names
  for_each = toset(var.bucket_names)

  # Bucket Naming Determinism: name-env-purpose-account-id (required contract)
  bucket = "${var.project_name}-${var.environment}-${each.key}-${data.aws_caller_identity.current.account_id}"
  
  # Crucial for Teardown: MUST be set for non-empty bucket deletion via 'terraform destroy'
  force_destroy = true 

  tags = {
    Name    = "${var.project_name}-${each.key}-storage"
    Purpose = each.key
  }
}

# 3. Apply Public Access Block (Security Best Practice)
resource "aws_s3_bucket_public_access_block" "block" {
  for_each = aws_s3_bucket.app_storage
  bucket = each.value.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# 4. Enforce Bucket Ownership (CRITICAL for EKS/IRSA functionality)
# Ensures S3 owner enforced setting to prevent permission issues with IRSA roles.
resource "aws_s3_bucket_ownership_controls" "ownership" {
  for_each = aws_s3_bucket.app_storage
  bucket = each.value.id

  rule {
    object_ownership = "BucketOwnerEnforced"
  }
}

# 5. Enable Versioning (Best Practice for ML Artifacts/Logs)
resource "aws_s3_bucket_versioning" "versioning" {
  for_each = aws_s3_bucket.app_storage
  bucket = each.value.id

  versioning_configuration {
    status = "Enabled"
  }
}

# 6. Server-Side Encryption (Fulfills KMS contract in variables)
resource "aws_s3_bucket_server_side_encryption_configuration" "encryption" {
  for_each = aws_s3_bucket.app_storage
  bucket = each.value.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.kms_key_alias
      sse_algorithm     = "aws:kms"
    }
  }
}
