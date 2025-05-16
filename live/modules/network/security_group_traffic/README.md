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

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_security_group_rule.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.secondary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_create_explicit_egress_to_target_security_group"></a> [create\_explicit\_egress\_to\_target\_security\_group](#input\_create\_explicit\_egress\_to\_target\_security\_group) | Whether to create an explicit egress rule from the source SG to the target SG. Ignored unless 'type' is 'egress' and 'target' is a security group | `bool` | `false` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of this rule's purpose (e.g. 'allow instances to reach database') | `string` | n/a | yes |
| <a name="input_ports"></a> [ports](#input\_ports) | List of ports that this rule will apply to; [0] for all ports | `list(number)` | n/a | yes |
| <a name="input_protocol"></a> [protocol](#input\_protocol) | 'tcp' or 'udp'; if null, defaults to 'tcp' | `string` | `"tcp"` | no |
| <a name="input_security_group_id"></a> [security\_group\_id](#input\_security\_group\_id) | Security group ID to which this rule will be attached | `string` | n/a | yes |
| <a name="input_target"></a> [target](#input\_target) | CIDR block, 'self', or other security group ID to allow 'security\_group\_id' to egress/ingress to/from | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | ingress or egress | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_rule_ids"></a> [rule\_ids](#output\_rule\_ids) | IDs of any rules created on 'target' or 'security\_group\_id'. At least one element will be present; two if 'create\_explicit\_egress\_to\_target\_security\_group' was set. |
<!-- END_TF_DOCS -->