# ----------------------------------------------------------------------------------
# ACM Certificate
# This module requests a wildcard certificate for the base domain and validates it
# using DNS records in the specified Route 53 hosted zone.
# The ARN of this certificate will be used by the AWS Load Balancer Controller
# (ALBC) for the ClearML Ingress.
# ----------------------------------------------------------------------------------

resource "aws_acm_certificate" "clearml_wildcard" {
  # Request a wildcard certificate for the base domain to cover all subdomains
  # (api, app, files, router, etc.)
  domain_name       = "*.${var.base_domain}"
  validation_method = "DNS"
  tags = {
    Name = "clearml-${var.base_domain}-wildcard"
  }

  lifecycle {
    # Ensure the certificate is not accidentally replaced or deleted during destroy
    create_before_destroy = true
  }
}

# ----------------------------------------------------------------------------------
# Route 53 DNS Validation
# Creates the necessary CNAME records in Route 53 to prove ownership of the domain
# and complete the ACM validation process.
# ----------------------------------------------------------------------------------

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for domain in aws_acm_certificate.clearml_wildcard.domain_validation_options : domain.domain_name => {
      name    = domain.resource_record_name
      record  = domain.resource_record_value
      type    = domain.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  type            = each.value.type
  zone_id         = var.hosted_zone_id
  records         = [each.value.record]
  ttl             = 60
}

# ----------------------------------------------------------------------------------
# Certificate Validation Status
# Waits for the certificate to be issued and validated before outputting the ARN.
# ----------------------------------------------------------------------------------

resource "aws_acm_certificate_validation" "clearml_certificate" {
  certificate_arn         = aws_acm_certificate.clearml_wildcard.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}
