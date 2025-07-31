# ACM Certificate Module

This module creates AWS Certificate Manager (ACM) certificates. It supports both single certificate creation (legacy mode) and multiple certificate creation using a map configuration.

## Usage

### Single Certificate (Legacy Mode)

```hcl
module "acm" {
  source = "./modules/acm"

  domain_name               = "example.com"
  subject_alternative_names = ["*.example.com", "api.example.com"]
  validation_method         = "DNS"
  
  tags = {
    Environment = "production"
    Project     = "web-app"
  }
}
```

### Multiple Certificates (New Mode)

```hcl
module "acm" {
  source = "./modules/acm"

  certificates = {
    web = {
      domain_name               = "example.com"
      subject_alternative_names = ["*.example.com"]
      validation_method         = "DNS"
      tags = {
        Environment = "production"
        Application = "web"
      }
    }
    api = {
      domain_name       = "api.example.com"
      validation_method = "DNS"
      key_algorithm     = "EC_prime256v1"
      tags = {
        Environment = "production"
        Application = "api"
      }
    }
    private = {
      domain_name               = "internal.example.com"
      certificate_authority_arn = "arn:aws:acm-pca:us-east-1:123456789012:certificate-authority/12345678-1234-1234-1234-123456789012"
      tags = {
        Environment = "production"
        Application = "internal"
      }
    }
  }
}
```

### Accessing Outputs

#### Single Certificate Mode
```hcl
# Legacy outputs (deprecated but still supported)
output "cert_arn" {
  value = module.acm.certificate_arn
}
```

#### Multiple Certificates Mode
```hcl
# New map-based outputs
output "web_cert_arn" {
  value = module.acm.certificates["web"].arn
}

output "api_cert_arn" {
  value = module.acm.certificates["api"].arn
}

# Or access all certificates
output "all_certificates" {
  value = module.acm.certificates
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_acm_certificate.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/acm_certificate) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_certificate_authority_arn"></a> [certificate\_authority\_arn](#input\_certificate\_authority\_arn) | ARN of the Private Certificate Authority to use for issuing private certificates. If null, creates a public certificate. | `string` | `null` | no |
| <a name="input_certificates"></a> [certificates](#input\_certificates) | Map of certificate configurations. Each key is a certificate name. | <pre>map(object({<br/>    domain_name               = string<br/>    subject_alternative_names = optional(set(string), [])<br/>    validation_method         = optional(string, "DNS")<br/>    validate_certificate      = optional(bool, true)<br/>    validation_record_fqdns   = optional(list(string), [])<br/>    validation_timeout        = optional(string, "5m")<br/>    key_algorithm             = optional(string, "RSA_2048")<br/>    certificate_authority_arn = optional(string, null)<br/>    tags                      = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The domain name for which the certificate should be issued (deprecated - use certificates map) | `string` | `null` | no |
| <a name="input_key_algorithm"></a> [key\_algorithm](#input\_key\_algorithm) | Specifies the algorithm of the public and private key pair that your Amazon issued certificate uses to encrypt data | `string` | `"RSA_2048"` | no |
| <a name="input_subject_alternative_names"></a> [subject\_alternative\_names](#input\_subject\_alternative\_names) | Set of domains that should be SANs in the issued certificate (deprecated - use certificates map) | `set(string)` | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to add to the certificate | `map(string)` | `{}` | no |
| <a name="input_validate_certificate"></a> [validate\_certificate](#input\_validate\_certificate) | Whether to validate the certificate. Only applicable when validation\_method is DNS | `bool` | `true` | no |
| <a name="input_validation_method"></a> [validation\_method](#input\_validation\_method) | Method to use for validation. Valid values are DNS, EMAIL, or NONE | `string` | `"DNS"` | no |
| <a name="input_validation_record_fqdns"></a> [validation\_record\_fqdns](#input\_validation\_record\_fqdns) | List of FQDNs that implement the validation. Only valid for DNS validation method | `list(string)` | `[]` | no |
| <a name="input_validation_timeout"></a> [validation\_timeout](#input\_validation\_timeout) | Timeout for certificate validation | `string` | `"5m"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certificate_arn"></a> [certificate\_arn](#output\_certificate\_arn) | The ARN of the certificate (deprecated - use certificates map) |
| <a name="output_certificate_domain_name"></a> [certificate\_domain\_name](#output\_certificate\_domain\_name) | The domain name for which the certificate is issued (deprecated - use certificates map) |
| <a name="output_certificate_domain_validation_options"></a> [certificate\_domain\_validation\_options](#output\_certificate\_domain\_validation\_options) | Set of domain validation objects which can be used to complete certificate validation (deprecated - use certificates map) |
| <a name="output_certificate_key_algorithm"></a> [certificate\_key\_algorithm](#output\_certificate\_key\_algorithm) | Specifies the algorithm of the public and private key pair (deprecated - use certificates map) |
| <a name="output_certificate_not_after"></a> [certificate\_not\_after](#output\_certificate\_not\_after) | Expiration date and time of the certificate (deprecated - use certificates map) |
| <a name="output_certificate_not_before"></a> [certificate\_not\_before](#output\_certificate\_not\_before) | Start of the validity period of the certificate (deprecated - use certificates map) |
| <a name="output_certificate_renewal_eligibility"></a> [certificate\_renewal\_eligibility](#output\_certificate\_renewal\_eligibility) | Whether the certificate is eligible for renewal (deprecated - use certificates map) |
| <a name="output_certificate_status"></a> [certificate\_status](#output\_certificate\_status) | Status of the certificate (deprecated - use certificates map) |
| <a name="output_certificate_subject_alternative_names"></a> [certificate\_subject\_alternative\_names](#output\_certificate\_subject\_alternative\_names) | Set of domains that are SANs in the issued certificate (deprecated - use certificates map) |
| <a name="output_certificate_type"></a> [certificate\_type](#output\_certificate\_type) | The source of the certificate (deprecated - use certificates map) |
| <a name="output_certificate_validation_emails"></a> [certificate\_validation\_emails](#output\_certificate\_validation\_emails) | List of addresses that received a validation email (deprecated - use certificates map) |
| <a name="output_certificates"></a> [certificates](#output\_certificates) | Map of certificate attributes by certificate name |
<!-- END_TF_DOCS -->