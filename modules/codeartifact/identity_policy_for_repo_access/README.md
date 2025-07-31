This module provides a re-usable template for generating identity-based IAM policies that give access to code artifact repositories.

Why?

Because while users will ask for access in terms of "Push" and "Pull", code artifact has much more complex granular permissions.

It is best to use the output of this module with the `aws_iam_policy_document` data resource and it's ability to merge policies

```terraform
data "aws_iam_policy_document" "policy" {
  source_policy_documents = [
    module.identity_policy_for_codeartifact_repo_access.policy.json
  ]
}
```
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
| <a name="module_access_policy_fragments"></a> [access\_policy\_fragments](#module\_access\_policy\_fragments) | ../access_policy_fragments | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_repositories"></a> [repositories](#input\_repositories) | ARNs for CodeArtifact repositories to which this policy should have access | <pre>object({<br/>    pull = optional(set(string), [])<br/>    push = optional(set(string), [])<br/>  })</pre> | <pre>{<br/>  "pull": [],<br/>  "push": []<br/>}</pre> | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_policy"></a> [policy](#output\_policy) | an aws\_iam\_policy\_document object |
<!-- END_TF_DOCS -->