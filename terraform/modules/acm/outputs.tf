output "certificate_arn" {
  description = "The ARN of the validated ClearML wildcard certificate."
  value       = aws_acm_certificate_validation.clearml_certificate.certificate_arn
}
