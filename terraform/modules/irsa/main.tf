# Kubernetes Service Account (created via Terraform K8s provider)
resource "kubernetes_service_account_v1" "sa" {
  metadata {
    name        = var.service_account
    namespace   = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.irsa.arn
    }
  }
}

# IAM Role and Policy Attachment
resource "aws_iam_role" "irsa" {
  name             = "${var.cluster_name}-${var.service_account}-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

# Policy Document for EKS Service Account to assume role
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    
    # --- CORRECTED PRINCIPALS BLOCK ---
    principals {
      type        = "Federated" 
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(var.oidc_issuer, "https://", "")}"
      ]
    }
    # ----------------------------------
    
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }
  }
}
# Define data source for AWS Caller Identity for use in policy (required for OIDC ARN)
data "aws_caller_identity" "current" {}

# IAM Policy Attachment
resource "aws_iam_role_policy" "sa_policy" {
  name  = "${var.service_account}-policy"
  role  = aws_iam_role.irsa.id
  policy = var.policy_document
}
