
variable "cluster_name" { type = string }
variable "cluster_version" { type = string }
variable "subnet_ids" { type = list(string) }
variable "nodegroup_definitions" { type = any } # Map of nodegroup configurations


