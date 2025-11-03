  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# ... (Additional resources for subnets, internet gateway, NAT gateway, routing tables) ...

