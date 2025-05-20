# Terragrunter IAM Role

This module provisions the role used by Platform administrators to do IaC management across Cloud City.

Each AWS account in Cloud City will have an instance of the `terragrunter` role with an accompanying policy that allows
broad IaC changes. As a result, Terragrunt is a sensitive, controlled resource that should be used (and given access to)
with immense care.

The required variable `iac_account_id` corresponds to which version of the Terragrunter role will be the "command and 
control" of BESPIN. That account's instance of `terragrunter` will be able to assume-role into all *other* accounts'
terragrunter roles to enable cross-account infrastructure management.

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
| <a name="module_iam_fragments"></a> [iam\_fragments](#module\_iam\_fragments) | ../../iam/fragments | n/a |
| <a name="module_terragrunter_policy"></a> [terragrunter\_policy](#module\_terragrunter\_policy) | ../../iam/policy | n/a |
| <a name="module_terragrunter_role"></a> [terragrunter\_role](#module\_terragrunter\_role) | ../../iam/role | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.terragrunter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_role_assumers"></a> [additional\_role\_assumers](#input\_additional\_role\_assumers) | Additional principals that should be allowed to assume the terragrunter role | `list(string)` | `[]` | no |
| <a name="input_iac_account_id"></a> [iac\_account\_id](#input\_iac\_account\_id) | AWS Account ID of the account that manages IaC and should be able to assume 'terragrunter' in other accounts | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to the resource | `map(string)` | `{}` | no |
| <a name="input_terragrunter_role_additional_policies"></a> [terragrunter\_role\_additional\_policies](#input\_terragrunter\_role\_additional\_policies) | Additional policies ARNs to apply to the Terragrunter Role | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_terragrunter_policy_arn"></a> [terragrunter\_policy\_arn](#output\_terragrunter\_policy\_arn) | The ARN of the Terragrunter IAM policy |
<!-- END_TF_DOCS -->