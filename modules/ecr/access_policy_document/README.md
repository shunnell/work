# `ecr/access_policy_document`

This module manages no resources, and outputs a document that permits management of a set of ECR repositories or 
repository prefixes for a particular action (view, push, or pull). 

The produced documents can be used for both identity-based access management (in which case principals should not be
specified), or resource-based access management (in which case repositories should not be specified).

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
| [aws_caller_identity.ecr_account](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.ecr_region](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_action"></a> [action](#input\_action) | 'view', 'push', 'delete', or 'pull' | `string` | n/a | yes |
| <a name="input_conditions"></a> [conditions](#input\_conditions) | n/a | <pre>list(object({<br/>    test     = string<br/>    variable = string<br/>    values   = set(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_principals"></a> [principals](#input\_principals) | n/a | `set(string)` | `[]` | no |
| <a name="input_repositories"></a> [repositories](#input\_repositories) | Set of repo names (not ARNs; all repos will be referenced in the infra account) | `set(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_json"></a> [json](#output\_json) | an aws\_iam\_policy\_document object |
| <a name="output_repository_arns"></a> [repository\_arns](#output\_repository\_arns) | Set of repository ARNs managed by this document |
<!-- END_TF_DOCS -->