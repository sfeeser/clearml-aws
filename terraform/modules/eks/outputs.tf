
output "cluster_name" {
  value = aws_eks_cluster.main.id
}
output "cluster_endpoint" {
  value = aws_eks_cluster.main.endpoint
}
output "cluster_certificate_authority_data" {
  value = aws_eks_cluster.main.certificate_authority[0].data
}
output "kubeconfig_path" {
  value = "${var.cluster_name}.kubeconfig" # Matches null_resource command
}


