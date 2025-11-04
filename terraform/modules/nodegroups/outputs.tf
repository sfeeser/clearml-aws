output "nodegroup_names" {
  value = values(aws_eks_node_group.workers)[*].id
}
