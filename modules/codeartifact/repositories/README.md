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
| [aws_codeartifact_domain.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_domain) | resource |
| [aws_codeartifact_repository.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/codeartifact_repository) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_domain"></a> [create\_domain](#input\_create\_domain) | Whether to create a new CodeArtifact domain | `bool` | `false` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name of the CodeArtifact domain | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | The ARN of a KMS key used for encrypting the domain's assets | `string` | `null` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | List of repositories to create in the domain | <pre>list(object({<br/>    name                  = string<br/>    description           = string<br/>    upstream_repositories = optional(list(string))<br/>    external_connections  = optional(list(string))<br/>  }))</pre> | `[]` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to assign to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_arn"></a> [domain\_arn](#output\_domain\_arn) | The ARN of the CodeArtifact domain |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | The name of the CodeArtifact domain |
| <a name="output_domain_owner"></a> [domain\_owner](#output\_domain\_owner) | The AWS account ID that owns the domain |
| <a name="output_domain_url"></a> [domain\_url](#output\_domain\_url) | The URL of the CodeArtifact domain |
| <a name="output_repositories"></a> [repositories](#output\_repositories) | Map of created repositories |
<!-- END_TF_DOCS -->