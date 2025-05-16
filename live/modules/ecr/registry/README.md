# `ecr/registry`

This module establishes "common" pull through cache repositories, such as docker-hub.

It grants access via organizational units, which reduces the amount of effort to support allowing re-use across BESPIN.
s
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
| <a name="module_pull_policy_document"></a> [pull\_policy\_document](#module\_pull\_policy\_document) | ../access_policy_document | n/a |
| <a name="module_pull_through_policy_document"></a> [pull\_through\_policy\_document](#module\_pull\_through\_policy\_document) | ../access_policy_document | n/a |
| <a name="module_pull_through_secrets"></a> [pull\_through\_secrets](#module\_pull\_through\_secrets) | ../../secret | n/a |
| <a name="module_view_policy_document"></a> [view\_policy\_document](#module\_view\_policy\_document) | ../access_policy_document | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_pull_through_cache_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_repository_creation_template.template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_creation_template) | resource |
| [aws_caller_identity.ecr_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.ecr_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_pull_organizational_units"></a> [pull\_organizational\_units](#input\_pull\_organizational\_units) | The organizational units which will be granted pull access to this registry (push should be granted to account-local principals separately and not managed by this module) | `set(string)` | n/a | yes |
| <a name="input_pull_through_organizational_units"></a> [pull\_through\_organizational\_units](#input\_pull\_through\_organizational\_units) | The organizational units which will be granted pull through access to this registry (push should be granted to account-local principals separately and not managed by this module) | `set(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_uri"></a> [ecr\_repository\_uri](#output\_ecr\_repository\_uri) | URI of the ECR repository managed by this module (which exists regardless), without https:// prefix. This output blocks on full configuration of that repo, for convenience of terraform/terragrunt dependency management. |
| <a name="output_pull_through_cache_rules"></a> [pull\_through\_cache\_rules](#output\_pull\_through\_cache\_rules) | Pull through cache rule IDs, keyed by repo prefix (which corresponds to the provider of the upstream) |
<!-- END_TF_DOCS -->