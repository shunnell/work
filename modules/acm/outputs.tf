# New map-based outputs for multiple certificates
output "certificates" {
  description = "Map of certificate attributes by certificate name"
  value = {
    for k, v in aws_acm_certificate.this : k => {
      arn                       = v.arn
      domain_name               = v.domain_name
      status                    = v.status
      subject_alternative_names = v.subject_alternative_names
      domain_validation_options = v.domain_validation_options
      validation_emails         = v.validation_emails
      not_before                = v.not_before
      not_after                 = v.not_after
      key_algorithm             = v.key_algorithm
      renewal_eligibility       = v.renewal_eligibility
      type                      = v.type
    }
  }
}

# Legacy single certificate outputs for backward compatibility
output "certificate_arn" {
  description = "The ARN of the certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].arn : null
}

output "certificate_domain_name" {
  description = "The domain name for which the certificate is issued (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].domain_name : null
}

output "certificate_status" {
  description = "Status of the certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].status : null
}

output "certificate_subject_alternative_names" {
  description = "Set of domains that are SANs in the issued certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].subject_alternative_names : null
}

output "certificate_domain_validation_options" {
  description = "Set of domain validation objects which can be used to complete certificate validation (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].domain_validation_options : null
}

output "certificate_validation_emails" {
  description = "List of addresses that received a validation email (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].validation_emails : null
}

output "certificate_not_before" {
  description = "Start of the validity period of the certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].not_before : null
}

output "certificate_not_after" {
  description = "Expiration date and time of the certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].not_after : null
}

output "certificate_key_algorithm" {
  description = "Specifies the algorithm of the public and private key pair (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].key_algorithm : null
}

output "certificate_renewal_eligibility" {
  description = "Whether the certificate is eligible for renewal (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].renewal_eligibility : null
}

output "certificate_type" {
  description = "The source of the certificate (deprecated - use certificates map)"
  value       = var.domain_name != null ? aws_acm_certificate.this["default"].type : null
}