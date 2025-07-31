locals {
  # Create certificates map from either the new certificates variable or legacy single certificate variables
  certificates = var.domain_name != null ? {
    default = {
      domain_name               = var.domain_name
      subject_alternative_names = var.subject_alternative_names
      validation_method         = var.validation_method
      validate_certificate      = var.validate_certificate
      validation_record_fqdns   = var.validation_record_fqdns
      validation_timeout        = var.validation_timeout
      key_algorithm             = var.key_algorithm
      certificate_authority_arn = var.certificate_authority_arn
      tags                      = var.tags
    }
  } : var.certificates
}

resource "aws_acm_certificate" "this" {
  for_each = local.certificates

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  certificate_authority_arn = each.value.certificate_authority_arn

  key_algorithm = each.value.key_algorithm

  tags = each.value.tags

  lifecycle {
    create_before_destroy = true
  }
}
