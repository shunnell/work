variable "certificates" {
  description = "Map of certificate configurations. Each key is a certificate name."
  type = map(object({
    domain_name               = string
    subject_alternative_names = optional(set(string), [])
    validation_method         = optional(string, "DNS")
    validate_certificate      = optional(bool, true)
    validation_record_fqdns   = optional(list(string), [])
    validation_timeout        = optional(string, "5m")
    key_algorithm             = optional(string, "RSA_2048")
    certificate_authority_arn = optional(string, null)
    tags                      = optional(map(string), {})
  }))
  default = {}
}

variable "domain_name" {
  description = "The domain name for which the certificate should be issued (deprecated - use certificates map)"
  type        = string
  default     = null
}

variable "subject_alternative_names" {
  description = "Set of domains that should be SANs in the issued certificate (deprecated - use certificates map)"
  type        = set(string)
  default     = []
}

variable "validation_method" {
  description = "Method to use for validation. Valid values are DNS, EMAIL, or NONE"
  type        = string
  default     = "DNS"
  validation {
    condition     = contains(["DNS", "EMAIL", "NONE"], var.validation_method)
    error_message = "Validation method must be one of: DNS, EMAIL, or NONE."
  }
}

variable "validate_certificate" {
  description = "Whether to validate the certificate. Only applicable when validation_method is DNS"
  type        = bool
  default     = true
}

variable "validation_record_fqdns" {
  description = "List of FQDNs that implement the validation. Only valid for DNS validation method"
  type        = list(string)
  default     = []
}

variable "validation_timeout" {
  description = "Timeout for certificate validation"
  type        = string
  default     = "5m"
}

variable "key_algorithm" {
  description = "Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data"
  type        = string
  default     = "RSA_2048"
  validation {
    condition = contains([
      "RSA_1024", "RSA_2048", "RSA_3072", "RSA_4096",
      "EC_prime256v1", "EC_secp384r1", "EC_secp521r1"
    ], var.key_algorithm)
    error_message = "Key algorithm must be one of: RSA_1024, RSA_2048, RSA_3072, RSA_4096, EC_prime256v1, EC_secp384r1, or EC_secp521r1."
  }
}

variable "certificate_authority_arn" {
  description = "ARN of the Private Certificate Authority to use for issuing private certificates. If null, creates a public certificate."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to add to the certificate"
  type        = map(string)
  default     = {}
}