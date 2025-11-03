# IAM Role for EKS Cluster
resource "aws_iam_role" "cluster" {
  name = "${var.cluster_name}-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Helper script to write kubeconfig file as per output contract
resource "null_resource" "kubeconfig_writer" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks update-kubeconfig \
      --name ${aws_eks_cluster.main.name} \
      --region ${var.region} \
      --kubeconfig ${var.cluster_name}.kubeconfig
    EOT
  }
}

