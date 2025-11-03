# IAM Role and Policy Attachment
resource "aws_iam_role" "irsa" {
  name               = "${var.cluster_name}-${var.service_account}-role"
  assume_role_policy = data.aws_iam_policy_document.irsa_assume_role.json
}

# Policy Document for EKS Service Account to assume role
data "aws_iam_policy_document" "irsa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principal {
      federated = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}"
      type      = "Federated"
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.main.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account}"]
    }
  }
}

# IAM Policy Attachment
resource "aws_iam_role_policy" "sa_policy" {
  name   = "${var.service_account}-policy"
  role   = aws_iam_role.irsa.id
  policy = var.policy_document
}

