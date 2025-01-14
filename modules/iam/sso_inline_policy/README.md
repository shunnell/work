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
| [aws_ssoadmin_permission_set_inline_policy.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_inline_policy"></a> [inline\_policy](#input\_inline\_policy) | Inline policy JSON document to attach to the permission set | `string` | n/a | yes |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The Amazon Resource Name (ARN) of the SSO Instance | `string` | n/a | yes |
| <a name="input_permission_set_arn"></a> [permission\_set\_arn](#input\_permission\_set\_arn) | The ARN of the Permission Set | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_inline_policy_arn"></a> [inline\_policy\_arn](#output\_inline\_policy\_arn) | The ARN of the Inline Policy |
<!-- END_TF_DOCS -->