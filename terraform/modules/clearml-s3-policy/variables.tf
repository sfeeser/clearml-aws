# -----------------------------------------------------------------------------
# VARIABLES for clearml-s3-policy module
# -----------------------------------------------------------------------------

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket ClearML will use for storing artifacts and models."
  type        = string
}
