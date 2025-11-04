# Define data source for AWS Caller Identity for use in policy (required for OIDC ARN)
data "aws_caller_identity" "current" {}

# Kubernetes Service Account (created via Terraform K8s provider)
# This resource creates the in-cluster identity which will be annotated 
# with the ARN of the IAM Role it is allowed to assume.
resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name      = var.service_account
    namespace = var.namespace
    annotations = {
      # This tag links the K8s SA to the AWS IAM Role
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa.arn
    }
  }
}

# IAM Role and Policy Attachment
# This is the role that the Kubernetes Service Account will assume.
resource "aws_iam_role" "irsa" {
  name               = "${var.cluster_name}-${var.service_account}-role"
  # The trust policy (assume_role_policy) is defined by the data block below
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

# Policy Document for EKS Service Account to assume role (The Trust Policy)
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    # 1. Action: The service account must be allowed to perform this STS action
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    # 2. Principal: Who is allowed to perform the action? 
    # It must be a Federated identity (the EKS OIDC Provider).
    principal {
      type        = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_issuer, "https://", "")}"
      ]
    }

    # 3. Condition: The most crucial part. The role can only be assumed if 
    # the request comes from the SPECIFIC service account in the SPECIFIC namespace.
    condition {
      test     = "StringEquals"
      # The key to check (the OIDC subject claim)
      variable = "${replace(var.oidc_issuer, "https://", "")}:sub"
      # The required value (namespace:serviceaccount)
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }
  }
}

# IAM Policy Attachment
# This resource attaches the actual permissions (e.g., S3 read/write) 
# which is passed in as a variable from the root module.
resource "aws_iam_role_policy" "sa_policy" {
  name   = "${var.service_account}-policy"
  role   = aws_iam_role.irsa.id
  policy = var.policy_document
}
