variable "project_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "bucket_names" {
  description = "List of required S3 buckets (e.g., artifacts, datasets, logs)"
  type        = list(string)
}
variable "kms_key_alias" { type = string }
