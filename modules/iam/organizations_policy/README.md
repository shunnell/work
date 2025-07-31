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
| <a name="module_policy"></a> [policy](#module\_policy) | ../modified_policy_document | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_organizations_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy) | resource |
| [aws_organizations_policy_attachment.attachment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/organizations_policy_attachment) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_bypass_for_principal_arns"></a> [bypass\_for\_principal\_arns](#input\_bypass\_for\_principal\_arns) | Set of ARNs to *not* apply the policy for. | `set(string)` | `[]` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the SCP/RCP | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the SCP/RCP | `string` | n/a | yes |
| <a name="input_organizational_units_or_account_ids"></a> [organizational\_units\_or\_account\_ids](#input\_organizational\_units\_or\_account\_ids) | Set of organizational unit (OU) IDs or AWS account IDs to apply this SCP/RCP to. | `set(string)` | n/a | yes |
| <a name="input_policies"></a> [policies](#input\_policies) | Set of policy documents to combine into this SCP/RCP. All statements in 'policies' must have 'Deny' effects. | `set(string)` | n/a | yes |
| <a name="input_service_control_policy"></a> [service\_control\_policy](#input\_service\_control\_policy) | If true, create a service control policy. If false, create a resource control policy. | `bool` | `true` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all AWS resources | `map(string)` | `{}` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->