# ----------------------------------------------------------------------------------
# S3 PERMISSIONS POLICY DOCUMENT FOR CLEARML FILESERVER
#
# This module is now responsible only for defining the specific S3 access
# permissions required by the ClearML Fileserver component (including the
# Presign Service) to read and write artifacts and models.
#
# The resulting JSON document should be passed to your generic IRSA module
# via the 'policy_document' variable.
# ----------------------------------------------------------------------------------

# IAM Policy Document: Grants necessary S3 permissions.
# This data block generates the policy JSON.
data "aws_iam_policy_document" "clearml_fileserver_s3_policy" {
  statement {
    sid    = "S3AccessForClearMLFileserver"
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket",
      "s3:GetBucketLocation",
      "s3:ListMultipartUploadParts",
    ]
    # Grant access to the bucket itself and all objects within it.
    resources = [
      var.s3_bucket_arn,
      "${var.s3_bucket_arn}/*",
    ]
  }
}
