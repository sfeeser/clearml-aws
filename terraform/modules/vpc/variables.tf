variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}
variable "environment" {
  description = "Environment name for resource tagging"
  type        = string
}
variable "vpc_cidr" {
  description = "The CIDR block for the VPC (e.g., 10.0.0.0/16)"
  type        = string
}
variable "region" {
  description = "AWS region"
  type        = string
}
