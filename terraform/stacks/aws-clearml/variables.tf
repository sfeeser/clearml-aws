
variable "config_path" {
  description = "Path to the shared configuration YAML file (e.g., spec/config.yaml)"
  type        = string
  default     = "../../spec/config.yaml"
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}


