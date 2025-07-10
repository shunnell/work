# `iam/role`

This module encodes the Cloud City "House Rules" for how IAM roles should be configured according to our best practices.

It provisions a single IAM role with a specified assume-role policy and attached trust policies.

Specifically, this module provides the following features and controls:
- Policies can only be attached to a role using this module, not externally/after a role is created. Extraneous/external policy attachments to the role are removed. This enhances security by self-correcting external drift, and discourages confusing code wherein the attachment of policies to a role is scattered all over the codebase.
- User defined access policy JSON documents can be passed in as strings; policies will be created internally and attached to the role. This saves a common source of boilerplate/extra code: policy documents that will only ever be used by one role.
- Requires that roles must have either a name or a name prefix, no `terraform-012030010001010`-only naming.
- Provides a shorthand for defining common trust policies (which principals can `sts:AssumeRole` into a role). For simple IAM principal and AWS service trust policies, role assumption permissions can be set via e.g. `assume_role_principals = ["ec2.amazonaws.com", "arn:aws:iam:::user/foobar"]`. If a more complex trust policy is needed, one can be supplied to the `trust_policy_json` variable.

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
| <a name="module_manual_policies"></a> [manual\_policies](#module\_manual\_policies) | ../policy | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_role.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policies_exclusive.ensure_no_inline_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policies_exclusive) | resource |
| [aws_iam_role_policy_attachment.attachments_external](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.attachments_manual](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachments_exclusive.policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachments_exclusive) | resource |
| [aws_iam_policy_document.assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_assume_role_principals"></a> [assume\_role\_principals](#input\_assume\_role\_principals) | Shorthand specification of sts:AssumeRole service or ARN/AWS principals which can assume this role. Info about principals that can assume this role. A set of either service names (ending in .amazonaws.com) or ARNs of 'iam:' or 'sts:' principals that can assume this role. All specified principals will be granted unconditional allow for sts:AssumeRole into this role. If a more specific assume policy is needed (e.g. conditions, denies, string-matches, etc), supply trust\_policy\_json instead. | `set(string)` | `[]` | no |
| <a name="input_condition_trust_policy"></a> [condition\_trust\_policy](#input\_condition\_trust\_policy) | Condition to apply to the trust policy | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = list(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Human-readable description of the IAM role | `string` | `""` | no |
| <a name="input_permissions_boundary_policy_arn"></a> [permissions\_boundary\_policy\_arn](#input\_permissions\_boundary\_policy\_arn) | ARN of an IAM policy to use as a permissions boundary for this role, if any | `string` | `null` | no |
| <a name="input_policy_arns"></a> [policy\_arns](#input\_policy\_arns) | The associated IAM policy ARNs to attach | `list(string)` | `[]` | no |
| <a name="input_policy_json_documents"></a> [policy\_json\_documents](#input\_policy\_json\_documents) | Map of descriptive policy name to JSON strings of policy documents to create and attach to this role (e.g. the output of data.aws\_iam\_policy\_document.whatever.json) | `map(string)` | `{}` | no |
| <a name="input_role_name"></a> [role\_name](#input\_role\_name) | Name of the IAM role (one of role\_name or role\_name\_prefix must be set) | `string` | `null` | no |
| <a name="input_role_name_prefix"></a> [role\_name\_prefix](#input\_role\_name\_prefix) | Name of the IAM role  (one of role\_name or role\_name\_prefix must be set) | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |
| <a name="input_trust_policy_json"></a> [trust\_policy\_json](#input\_trust\_policy\_json) | The trust policy of the IAM role; must be a JSON string. Set this if assume\_role\_principals cannot express the trust policy needed. | `string` | `"{}"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_role_arn"></a> [role\_arn](#output\_role\_arn) | The ARN of the IAM role |
| <a name="output_role_name"></a> [role\_name](#output\_role\_name) | The name of the IAM role |
<!-- END_TF_DOCS -->