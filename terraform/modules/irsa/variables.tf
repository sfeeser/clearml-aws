
variable "cluster_name" { type = string }
variable "oidc_issuer" { type = string } # <--- NEW INPUT
variable "namespace" { type = string }
variable "service_account" { type = string }
variable "policy_document" { type = string } # JSON IAM policy from root module


