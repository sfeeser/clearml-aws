variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
  default     = "clearml-dev"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.30"
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "m6i.xlarge"
}

variable "desired_nodes" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "key_name" {
  description = "EC2 Key Pair name"
  type        = string
  default     = "my-clearml-key"
}

variable "ssh_cidr" {
  description = "Your IP for SSH access (e.g., 203.0.113.10/32)"
  type        = string
  default     = "0.0.0.0/0"  # WARNING: Change to your IP!
}

