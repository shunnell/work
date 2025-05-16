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
| [aws_networkfirewall_firewall.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall) | resource |
| [aws_networkfirewall_firewall_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_firewall_policy) | resource |
| [aws_networkfirewall_logging_configuration.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alert_log_group_name"></a> [alert\_log\_group\_name](#input\_alert\_log\_group\_name) | Name of the alert log group | `string` | n/a | yes |
| <a name="input_flow_log_group_name"></a> [flow\_log\_group\_name](#input\_flow\_log\_group\_name) | Name of the flow log group | `string` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_rule_group_arns"></a> [rule\_group\_arns](#input\_rule\_group\_arns) | List of ARNs for the rule groups | `list(string)` | n/a | yes |
| <a name="input_subnet_mappings"></a> [subnet\_mappings](#input\_subnet\_mappings) | List of subnet IDs for firewall endpoints | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |
| <a name="input_tls_log_group_name"></a> [tls\_log\_group\_name](#input\_tls\_log\_group\_name) | Name of the TLS log group | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the VPC where the firewall will be deployed | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_endpoint_ids"></a> [endpoint\_ids](#output\_endpoint\_ids) | List of VPC endpoint IDs for the Network Firewall |
| <a name="output_firewall_arn"></a> [firewall\_arn](#output\_firewall\_arn) | ARN of the Network Firewall |
| <a name="output_firewall_id"></a> [firewall\_id](#output\_firewall\_id) | ID of the Network Firewall |
<!-- END_TF_DOCS -->