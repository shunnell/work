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
| [aws_ssoadmin_account_assignment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_account_assignment) | resource |
| [aws_identitystore_group.sso_group](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/identitystore_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_to_permission_set_map"></a> [account\_to\_permission\_set\_map](#input\_account\_to\_permission\_set\_map) | Mapping of AWS Account ID (key) to permission\_set\_arn (value). | `map(string)` | n/a | yes |
| <a name="input_group_display_name"></a> [group\_display\_name](#input\_group\_display\_name) | The name of the group | `string` | n/a | yes |
| <a name="input_identity_store_id"></a> [identity\_store\_id](#input\_identity\_store\_id) | The ID of the identity store associated with SSO instance | `string` | n/a | yes |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The Amazon Resource Name (ARN) of the SSO Instance | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->