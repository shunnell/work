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
| [aws_secretsmanager_secret.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.secret_externally_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.secret_fully_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_secretsmanager_secret_version.current_externally_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |
| [aws_secretsmanager_secret_version.current_fully_managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | Description of the secret. | `string` | n/a | yes |
| <a name="input_ignore_changes_to_secret_value"></a> [ignore\_changes\_to\_secret\_value](#input\_ignore\_changes\_to\_secret\_value) | If true, changes to the secret value in Terraform will be ignored after initial secret creation (assuming that the secret will be modified externally) | `bool` | `false` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the secret. | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Name prefix for the secret. Mutually exclusive with 'name'. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_value"></a> [value](#input\_value) | The secret. | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_secret_arn"></a> [secret\_arn](#output\_secret\_arn) | Secret ARN. |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | Secret ID. |
| <a name="output_secret_id_version"></a> [secret\_id\_version](#output\_secret\_id\_version) | A pipe delimited combination of secret ID and version ID. |
| <a name="output_secret_name"></a> [secret\_name](#output\_secret\_name) | Secret Name |
| <a name="output_secret_version_id"></a> [secret\_version\_id](#output\_secret\_version\_id) | Unique identifier of this version of the secret. |
<!-- END_TF_DOCS -->