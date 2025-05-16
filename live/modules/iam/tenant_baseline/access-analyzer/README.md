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
| [aws_accessanalyzer_analyzer.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/accessanalyzer_analyzer) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_analyzer_name"></a> [analyzer\_name](#input\_analyzer\_name) | The name of the organization external access analyzer. | `string` | `"cloudcity-access-analyzer"` | no |
| <a name="input_analyzer_type"></a> [analyzer\_type](#input\_analyzer\_type) | analyzer type should be specified | `string` | `"ACCOUNT"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_analyzer_name"></a> [analyzer\_name](#output\_analyzer\_name) | n/a |
<!-- END_TF_DOCS -->