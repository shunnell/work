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
| [aws_ssoadmin_application_assignment.vpn_assignment](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_application_assignment) | resource |
| [aws_identitystore_group.sso_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |
| [aws_ssoadmin_application.vpn](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ssoadmin_application) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_arn"></a> [application\_arn](#input\_application\_arn) | The ARN of the AWS SSO Application | `string` | n/a | yes |
| <a name="input_group_display_name"></a> [group\_display\_name](#input\_group\_display\_name) | The group display name as it appears in OKTA / Identity Center | `string` | n/a | yes |
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | n/a | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->