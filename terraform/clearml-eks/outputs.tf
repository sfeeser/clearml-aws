output "cluster_name" {
  value = module.eks.cluster_name
}

output "clearml_web_url" {
  value = "http://clearml.${replace(module.eks.cluster_endpoint, "https://", "")}"
}

output "s3_bucket" {
  value = aws_s3_bucket.clearml_artifacts.bucket
}

output "configure_kubectl" {
  value = "aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.aws_region}"
}
