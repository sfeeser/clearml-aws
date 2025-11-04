output "bucket_arns" {
  description = "A map of S3 bucket ARNs keyed by bucket purpose"
  value = { for k, v in aws_s3_bucket.app_storage : k => v.arn }
}
