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
| [aws_wafregional_web_acl.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl) | resource |
| [aws_wafregional_web_acl_association.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafregional_web_acl_association) | resource |
| [aws_wafregional_subscribed_rule_group.managed](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/wafregional_subscribed_rule_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_managed_rule_id"></a> [managed\_rule\_id](#input\_managed\_rule\_id) | ID of the AWS-managed rule group. If provided, this will be used instead of the name. | `string` | `""` | no |
| <a name="input_managed_rule_name"></a> [managed\_rule\_name](#input\_managed\_rule\_name) | Name of the AWS-managed rule group | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix used for naming and ALB lookup. | `string` | n/a | yes |
| <a name="input_resource_arn"></a> [resource\_arn](#input\_resource\_arn) | Resource ARN to associate with this Web ACL. | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_web_acl_arn"></a> [web\_acl\_arn](#output\_web\_acl\_arn) | WAF Classic (regional) Web ACL ARN. |
| <a name="output_web_acl_id"></a> [web\_acl\_id](#output\_web\_acl\_id) | WAF Classic (regional) Web ACL ID. |
<!-- END_TF_DOCS -->