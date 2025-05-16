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
| <a name="module_identity_policies"></a> [identity\_policies](#module\_identity\_policies) | ../../iam/policy | n/a |
| <a name="module_identity_policy_documents"></a> [identity\_policy\_documents](#module\_identity\_policy\_documents) | ../access_policy_document | n/a |
| <a name="module_per_repo_pull_policy"></a> [per\_repo\_pull\_policy](#module\_per\_repo\_pull\_policy) | ../access_policy_document | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_repository.legacy_repositories](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_creation_template.template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_creation_template) | resource |
| [aws_ecr_repository_policy.legacy_repository_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts_with_pull_access"></a> [aws\_accounts\_with\_pull\_access](#input\_aws\_accounts\_with\_pull\_access) | List of AWS accounts that will be given pull access to this tenant's images | `set(string)` | `[]` | no |
| <a name="input_legacy_ecr_repository_names_to_be_migrated"></a> [legacy\_ecr\_repository\_names\_to\_be\_migrated](#input\_legacy\_ecr\_repository\_names\_to\_be\_migrated) | Legacy ECR repository names which will be created/managed by this module. This list should not be added to, and should be replaced with tenants pushing images into 'cloud-city/$tenant\_name/$repo' over time so that this variable can be removed. | `set(string)` | `[]` | no |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Name of the tenant, lower case, e.g. 'opr' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pull_policy"></a> [pull\_policy](#output\_pull\_policy) | Metadata relating to the IAM policy that permits pulling this tenant's container images |
| <a name="output_push_policy"></a> [push\_policy](#output\_push\_policy) | Metadata relating to the IAM policy that permits pushing this tenant's container images |
| <a name="output_repository_prefixes"></a> [repository\_prefixes](#output\_repository\_prefixes) | ECR repository paths or prefixes (not ARNs) for repositories owned by this tenant |
| <a name="output_view_policy"></a> [view\_policy](#output\_view\_policy) | Metadata relating to the IAM policy that permits viewing container images, and describing images for this tenant's images |
<!-- END_TF_DOCS -->