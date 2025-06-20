# `ecr/registry`

Don't make changes to this module without considering whether those changes will break or require changes to the
policies described in this wiki node: https://confluence.fan.gov/spaces/CCPL/pages/580191053**

This module establishes "common" permissions and behavior across the entire account-wide private registry for the account
in which it is instantiated. 

That includes:
- Permissions for pull-through on repository paths corresponding to tenants' pull-through prefixes/folders.
- Secrets used for tenants' pull-through cache rules.

**Note**: for a given tenant pull-through path (e.g. `/<tenant>/docker/<pull-through-image>`) to provide 
pull-through behavior in a given AWS account, the following must all be true:
1. This module must have pull-through client accounts listed in `aws_accounts_enabled_for_pull_through`.
2. An instance of `tenant_ecr_repositories` must be instantiated with the `tenant_name` variable set to the corresponding
   tenant's path.
3. That instance of `tenant_ecr_repositories` must also list the pull-through client accounts in the 
   `aws_accounts_with_pull_access` variable.

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
| <a name="module_pull_through_secrets"></a> [pull\_through\_secrets](#module\_pull\_through\_secrets) | ../../secret | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_registry_policy.accountwide_registry_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_registry_policy) | resource |
| [aws_caller_identity.ecr_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.accountwide_pull_through_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.ecr_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts_enabled_for_pull_through"></a> [aws\_accounts\_enabled\_for\_pull\_through](#input\_aws\_accounts\_enabled\_for\_pull\_through) | List of AWS accounts that can issue pull-through requests for per-tenant pullthrough images. Note: A tenant can only issue pull-through requests to an account if it is listed here *and* if an instance of 'tenant\_ecr\_repositories' is present for that tenant, with this same account listed in 'tenant\_ecr\_repositories.aws\_accounts\_with\_pull\_access'. | `set(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_ecr_repository_uri"></a> [ecr\_repository\_uri](#output\_ecr\_repository\_uri) | URI of the ECR repository managed by this module (which exists regardless), without https:// prefix. This output blocks on full configuration of that repo, for convenience of terraform/terragrunt dependency management. |
| <a name="output_pull_through_configurations"></a> [pull\_through\_configurations](#output\_pull\_through\_configurations) | Map of pull-through prefix to secret ARN used for authenticating to the upstream (or null, for no secret). |
<!-- END_TF_DOCS -->