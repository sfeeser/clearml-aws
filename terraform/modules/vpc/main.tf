
# Modular VPC with public/private subnets and NAT Gateway
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# ... (Additional resources for subnets, internet gateway, NAT gateway, routing tables) ...

