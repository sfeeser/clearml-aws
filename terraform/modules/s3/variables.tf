
variable "project_name" { type = string }
variable "environment" { type = string }
variable "region" { type = string }
variable "bucket_names" { type = list(string) }
variable "kms_key_alias" { type = string }

