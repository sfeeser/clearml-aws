  cluster_name    = var.cluster_name
  node_group_name = each.key
  subnet_ids      = var.subnet_ids
  instance_types  = each.value.instance_types
  disk_size       = each.value.disk_size

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  # ... (additional settings, tags, IAM role) ...
}

