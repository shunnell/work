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
| [aws_networkfirewall_rule_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/networkfirewall_rule_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allowed_domains"></a> [allowed\_domains](#input\_allowed\_domains) | List of allowed domains | `list(string)` | n/a | yes |
| <a name="input_capacity"></a> [capacity](#input\_capacity) | Capacity of the firewall | `number` | `100` | no |
| <a name="input_enable_http_host"></a> [enable\_http\_host](#input\_enable\_http\_host) | Enable HTTP host | `bool` | `false` | no |
| <a name="input_home_net_cidrs"></a> [home\_net\_cidrs](#input\_home\_net\_cidrs) | List of CIDRs for the home network | `list(string)` | n/a | yes |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_group_arn"></a> [rule\_group\_arn](#output\_rule\_group\_arn) | ARN of the Network Firewall Rule Group |
<!-- END_TF_DOCS -->