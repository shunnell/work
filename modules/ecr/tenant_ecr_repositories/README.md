# `tenant_ecr_repositories`

**Don't make changes to this module without considering whether those changes will break or require changes to the
policies described in this wiki node: https://confluence.fan.gov/spaces/CCPL/pages/580191053**

This module creates the IAM layout for a Cloud City tenant's ECR repositories. This layout consists of two families of
repository prefixes ("folders", more or less):

1. `381492150796.dkr.ecr.us-east-1.amazonaws.com/<tenant-name>/internal/`: "first party"/"home-made" images created and
    pushed by the tenant's CICD. Tenant IAM-SSO roles and tenant GitLab runners will automatically be granted permission
    to push to and create new repositories below this path.
2. `381492150796.dkr.ecr.us-east-1.amazonaws.com/<tenant-name>/<pull-through>/`, where `<pull-through>` is one of
    'docker', 'gitlab', 'github', 'ecr-public', 'k8s', or 'quay': these paths contain images requested for pullthrough
    by the tenant; if a tenant's IAM principal requests to pull an image that doesn't exist, it will be created by
    pulling and storing the image from the corresponding third-party upstream source. For example, asking for 
    `381492150796.dkr.ecr.us-east-1.amazonaws.com/foobar/docker/library/redis` from a sandbox account, IAM user, or
    CICD runner operated by the `foobar` tenant will result in this image being pulled and cached: https://hub.docker.com/_/redis

Code in `live` which invokes this module will make sure that each tenant's IAM locations (SSO users, sandbox accounts, EKS
clusters, and CICD runners) can push/pull from appropriate paths in the above ECR path layout.

## Legacy repositories

Many repositories were crated in ECR before the above naming scheme was instituted.

Legacy/grandfathered-in repositories which do not fall within that naming scheme can be supplied via the
`legacy_ecr_repository_names_to_be_migrated` variable, which will cause this module to create those repositories and
manage their permissions appropriately.

**Note** that removing repositories from that list will cause the repositories themselves to be destroyed, for ease of
clean-up of legacy artifacts. Other repositories created within the 
`381492150796.dkr.ecr.us-east-1.amazonaws.com/<tenant-name>/` prefix according to the expected/approved naming scheme
described above will not be individually managed by this module.

**Note** that grandfathered-in repositories may need to be `terragrunt import`ed into invocations of this module in
order to avoid "repository already exists" errors during apply.

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
| <a name="module_resource_policies"></a> [resource\_policies](#module\_resource\_policies) | ../access_policy_document | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ecr_pull_through_cache_rule.rule](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_pull_through_cache_rule) | resource |
| [aws_ecr_repository.legacy_repositories](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository) | resource |
| [aws_ecr_repository_creation_template.template](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_creation_template) | resource |
| [aws_ecr_repository_policy.legacy_repository_policies](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository_policy) | resource |
| [aws_iam_policy_document.repo_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_accounts_with_pull_access"></a> [aws\_accounts\_with\_pull\_access](#input\_aws\_accounts\_with\_pull\_access) | List of AWS accounts that will be given pull access to this tenant's images | `set(string)` | n/a | yes |
| <a name="input_legacy_ecr_repository_names_to_be_migrated"></a> [legacy\_ecr\_repository\_names\_to\_be\_migrated](#input\_legacy\_ecr\_repository\_names\_to\_be\_migrated) | Legacy ECR repository names which will be created/managed by this module. This list should not be added to, and should be replaced with tenants pushing images into '$tenant\_name/internal/$repo' over time so that this variable can be removed. | `set(string)` | `[]` | no |
| <a name="input_pull_through_configurations"></a> [pull\_through\_configurations](#input\_pull\_through\_configurations) | Map of pull-through prefix to secret ARN used for authenticating to the upstream (or null, for no secret). If a key is omitted from this variable, that pull-through cache rule will not be created for this tenant. | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags to apply to AWS resources | `map(string)` | `{}` | no |
| <a name="input_tenant_name"></a> [tenant\_name](#input\_tenant\_name) | Name of the tenant, lower case, e.g. 'opr' | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_pull_policy"></a> [pull\_policy](#output\_pull\_policy) | Metadata relating to the IAM policy that permits pulling this tenant's container images. |
| <a name="output_push_policy"></a> [push\_policy](#output\_push\_policy) | Metadata relating to the IAM policy that permits pushing this tenant's container images. |
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | Set of repository ARNs (corresponding to individial legacy repos or path prefixes ending in '/*') managed by this module. |
| <a name="output_view_policy"></a> [view\_policy](#output\_view\_policy) | Metadata relating to the IAM policy that permits viewing and describing this tenant's container images. |
<!-- END_TF_DOCS -->