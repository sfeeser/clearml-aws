
output "vpc_id" {
  description = "The VPC identifier"
  value       = aws_vpc.main.id
}
output "private_subnets" {
  description = "IDs of private subnets for EKS workers"
  value       = [aws_subnet.private_a.id]
}
output "public_subnets" {
  description = "IDs of public subnets for load balancers/NAT Gateway"
  value       = [aws_subnet.public_a.id]
}

