output "clearml_fileserver_s3_policy_json" {
  description = "The JSON string of the S3 access policy for the ClearML fileserver. Pass this to the generic IRSA module's 'policy_document' variable."
  value       = data.aws_iam_policy_document.clearml_fileserver_s3_policy.json
}
