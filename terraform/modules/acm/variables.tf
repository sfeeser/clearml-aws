 ----------------------------------------------------------------------------------
# ACM Module Variables
# ----------------------------------------------------------------------------------

variable "base_domain" {
  description = "The root domain for the ClearML deployment (e.g., clearml.sfeeser.com)."
  type        = string
}

variable "hosted_zone_id" {
  description = "The Route 53 Hosted Zone ID where the domain's DNS records are managed."
  type        = string
}
