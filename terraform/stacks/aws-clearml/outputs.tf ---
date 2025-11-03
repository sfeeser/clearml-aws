output "private_subnets" {
  description = "IDs of private subnets"
  value       = module.vpc.private_subnets
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks_cluster.cluster_name
}

output "cluster_endpoint" {
  description = "EKS control-plane endpoint"
  value       = module.eks_cluster.cluster_endpoint
}

output "kubeconfig_path" {
  description = "Path to generated kubeconfig file"
  value       = module.eks_cluster.kubeconfig_path
}

# S3 Storage Outputs (used by Ansible/ClearML config)
output "s3_artifacts" {
  description = "ARN for the ClearML artifacts bucket"
  value       = module.s3_storage.bucket_arns["artifacts"]
}

output "s3_datasets" {
  description = "ARN for the ClearML datasets bucket"
  value       = module.s3_storage.bucket_arns["datasets"]
}

output "s3_logs" {
  description = "ARN for the ClearML logs bucket"
  value       = module.s3_storage.bucket_arns["logs"]
}

# Optional ACM Certificate Output
output "certificate_arn" {
  description = "(Optional) ACM Certificate ARN for TLS/Ingress"
  value       = try(module.acm_cert[0].certificate_arn, null)
}


