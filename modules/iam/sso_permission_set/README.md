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
| [aws_ssoadmin_managed_policy_attachment.managed_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_description"></a> [description](#input\_description) | The description of the permission set | `string` | `null` | no |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The Amazon Resource Name (ARN) of the SSO Instance | `string` | n/a | yes |
| <a name="input_managed_policy_arns"></a> [managed\_policy\_arns](#input\_managed\_policy\_arns) | List of managed policy ARNs to attach to the permission set | `list(string)` | `[]` | no |
| <a name="input_permission_set_name"></a> [permission\_set\_name](#input\_permission\_set\_name) | The name of the permission set | `string` | n/a | yes |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | The length of time that the application user sessions are valid for | `string` | `"PT1H"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_set_arn"></a> [permission\_set\_arn](#output\_permission\_set\_arn) | The ARN of the Permission Set |
| <a name="output_permission_set_id"></a> [permission\_set\_id](#output\_permission\_set\_id) | The ID of the Permission Set |
<!-- END_TF_DOCS -->