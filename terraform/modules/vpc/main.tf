# -----------------------------------------------------------------------------
# VPC MODULE: The Virtual Private Server Rack (Single AZ)
# -----------------------------------------------------------------------------

# 1. The VPC (The Rack)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr # 10.0.0.0/16
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name        = "${var.project_name}-${var.environment}-vpc"
    Environment = var.environment
  }
}

# 2. Internet Gateway (The Main Uplink)
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. Public Subnet (The Demilitarized Zone VLAN - AZ A)
# Used for Load Balancers and NAT Gateway
resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24" # Single public subnet
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-a"
  }
}

# 4. Private Subnet (The Application Zone VLAN - AZ A)
# Used for EKS Worker Nodes
resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24" # Single private subnet
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "${var.project_name}-private-a"
  }
}

# 5. Elastic IP for NAT Gateway (The Fixed IP for Outbound)
resource "aws_eip" "nat" {
  vpc = true
}

# 6. NAT Gateway (The Outbound-Only Router/Firewall)
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_a.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "${var.project_name}-nat"
  }
}

# 7. Route Tables

# Route table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

# Route table for Private Subnets (traffic goes via NAT)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }
}
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private.id
}


# Data source to get the first AZ in the region for single-AZ deployment
data "aws_availability_zones" "available" {
  state = "available"
}
