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
| <a name="module_local_roles"></a> [local\_roles](#module\_local\_roles) | ../../iam/local_role_data | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_kms_alias.key_alias](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_alias) | resource |
| [aws_kms_key.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/kms_key) | resource |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.key_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_alias"></a> [alias](#input\_alias) | Key alias | `string` | n/a | yes |
| <a name="input_description"></a> [description](#input\_description) | Key description (human readable name) | `string` | n/a | yes |
| <a name="input_policy_stanzas"></a> [policy\_stanzas](#input\_policy\_stanzas) | Stanzas to add to the key policy | <pre>map(object({<br/>    conditions = optional(list(object({<br/>      test     = string<br/>      values   = list(string)<br/>      variable = string<br/>    })), [])<br/>    actions    = set(string)<br/>    principals = map(set(string)) # E.g. "AWS" = ["arn:aws:iam:foobar"]<br/>  }))</pre> | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to all resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_alias_arn"></a> [alias\_arn](#output\_alias\_arn) | Alias ARN of the created key |
| <a name="output_alias_name"></a> [alias\_name](#output\_alias\_name) | Alias name of the created key |
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the created key |
| <a name="output_id"></a> [id](#output\_id) | ID of the created key |
<!-- END_TF_DOCS -->