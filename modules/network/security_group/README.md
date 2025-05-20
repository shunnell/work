# `security_group_traffic`: Allow traffic to pass between a security group and other network locations

This module creates one or more `security_group_rule`s that allow traffic to pass between the security group which
"owns" its invocation (the `security_group_id` variable) and other locations. This wrapper provides the following
conventions and benefits:

- Simplified syntax for representing security group rules, as the `security_group_rule` is a notorious source of user confusion.
- Prevention of insecure or dangerous AWS behavior (like the -1 protocol opening all ports).
- `description` is required, to facilitate easy observation and debugging.
- "Reversed" security group rules are automatically created when the `target` is itself a security group (inbound rules
are added to that group when appropriate).
- Supports CIDR/netmask values and security group IDs in an ergonomic, uniform syntax.

**Note:** unlike a bare `security_group_rule` resource, this module **may or may not** create rules on the security
group specified in the `security_group_id` variable. It may instead or additionally create security group rules on
**remote** security groups specified in the `target` variable.
<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_rules"></a> [rules](#module\_rules) | ../security_group_traffic | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_security_group.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.allow_all_outbound](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_all_outbound_traffic"></a> [allow\_all\_outbound\_traffic](#input\_allow\_all\_outbound\_traffic) | Whether this security group should allow all outbound traffic | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the security group's purpose | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | Security group name (one of name and name\_prefix must be specified) | `string` | `null` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Security group name (one of name and name\_prefix must be specified) | `string` | `null` | no |
| <a name="input_rules"></a> [rules](#input\_rules) | Rules to add to this security group; a list of maps/objects to be supplied as arguments to the 'security\_group\_traffic' resource. | <pre>map(object({<br/>    protocol = optional(string)<br/>    type     = string<br/>    ports    = list(number)<br/>    target   = string<br/>    // create_explicit_egress_to_target_security_group intentionally omitted; it is defaulted based on 'allow_all_outbound_traffic'.<br/>  }))</pre> | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | Security group ID |
<!-- END_TF_DOCS -->