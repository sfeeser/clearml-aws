
# Dynamically creates a set of S3 buckets based on the list of bucket_names
resource "aws_s3_bucket" "app_storage" {
  for_each = toset(var.bucket_names)

  bucket = "${var.project_name}-${var.environment}-${each.key}-${data.aws_caller_identity.current.account_id}"
  
  # Crucial for determinism/teardown: SpecBook 4.0 requirement
  force_destroy = true 

  tags = {
    Name = "${var.project_name}-${each.key}-storage"
    Purpose = each.key
  }
}

# ... (Additional resources for bucket ownership controls, public access blocks) ...

