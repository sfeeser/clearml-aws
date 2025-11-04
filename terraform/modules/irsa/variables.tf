# ----------------------------------------------------------------------------------
# IRSA Module Variables
# ----------------------------------------------------------------------------------

variable "cluster_name" {
  description = "The name of the EKS cluster."
  type        = string
}

variable "eks_oidc_provider" {
  description = "The OIDC provider URL of the EKS cluster (e.g., oidc.eks.us-east-1.amazonaws.com/id/EXAMPLEID)."
  type        = string
}

variable "eks_oidc_provider_arn" {
  description = "The full ARN of the EKS OIDC provider."
  type        = string
}

variable "s3_bucket_arn" {
  description = "The ARN of the S3 bucket used by ClearML for artifact storage."
  type        = string
}
