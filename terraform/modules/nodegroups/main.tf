
# IAM Role for EKS Worker Nodes (Fixes Error 2)
resource "aws_iam_role" "node_group_role" {
  name = "${var.cluster_name}-nodegroup-role"
  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}

# Attach required policies to the node group role
resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
  ])
  policy_arn = each.value
  role       = aws_iam_role.node_group_role.name
}


# Dynamically creates EKS Managed Node Groups
resource "aws_eks_node_group" "workers" {
  for_each = var.nodegroup_definitions

  cluster_name    = var.cluster_name
  node_group_name = each.key
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size
  node_role_arn   = aws_iam_role.node_group_role.arn # <--- SUPPLIES REQUIRED ARGUMENT

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # ... (additional settings, tags, IAM role) ...
}

