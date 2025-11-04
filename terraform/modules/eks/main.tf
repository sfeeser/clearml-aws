# -----------------------------------------------------------------------------
# EKS MODULE: The Kubernetes Control Plane
# -----------------------------------------------------------------------------

# 1. IAM Role for EKS Cluster (The Cluster's Identity)
# Allows the EKS Control Plane to make calls to AWS services on your behalf (e.g., managing ENIs).
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

# Attach AmazonEKSClusterPolicy to the role
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

# 2. EKS Cluster resource (The Managed Kubernetes Controller)
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn

  # EKS control plane will live in the provided subnets
  vpc_config {
    subnet_ids              = var.private_subnets
    endpoint_private_access = true # Best practice: control plane API is accessible privately
    endpoint_public_access  = false # Best practice: public access off, only expose via secured path
  }
  
  version = var.cluster_version

  tags = {
    Name = var.cluster_name
  }
}

# 3. Kubeconfig Writer (Helper for connectivity)
# This writes the temporary kubeconfig file specified in the SpecBook output contract.
resource "null_resource" "kubeconfig_writer" {
  triggers = {
    cluster_id = aws_eks_cluster.main.id
  }

  provisioner "local-exec" {
    command = <<-EOT
      aws eks update-kubeconfig \
      --name ${aws_eks_cluster.main.name} \
      --region ${var.region} \
      --kubeconfig ${var.cluster_name}.kubeconfig
    EOT
    environment = {
      REGION = var.region
    }
  }
}
