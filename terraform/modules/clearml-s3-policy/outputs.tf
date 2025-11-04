# -----------------------------------------------------------------------------
# OUTPUTS for clearml-s3-policy module
# -----------------------------------------------------------------------------

output "policy_json" {
  description = "The JSON string of the generated S3 policy document for the ClearML Fileserver."
  value       = data.aws_iam_policy_document.clearml_fileserver_s3_policy.json
}
