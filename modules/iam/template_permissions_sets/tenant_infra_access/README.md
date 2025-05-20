This permission set module is for building tenant permission sets meant for the platform-infra account.
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
| <a name="module_ecr_view_all_repos_policy"></a> [ecr\_view\_all\_repos\_policy](#module\_ecr\_view\_all\_repos\_policy) | ../../../ecr/access_policy_document | n/a |
| <a name="module_identity_policy_for_codeartifact_repo_access"></a> [identity\_policy\_for\_codeartifact\_repo\_access](#module\_identity\_policy\_for\_codeartifact\_repo\_access) | ../../../codeartifact/identity_policy_for_repo_access | n/a |

## Resources

| Name | Type |
|------|------|
| [aws_ssoadmin_customer_managed_policy_attachment.policy_attachments](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_customer_managed_policy_attachment) | resource |
| [aws_ssoadmin_permission_set.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set) | resource |
| [aws_ssoadmin_permission_set_inline_policy.inline_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ssoadmin_permission_set_inline_policy) | resource |
| [aws_iam_policy_document.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allow_code_artifact_repositories"></a> [allow\_code\_artifact\_repositories](#input\_allow\_code\_artifact\_repositories) | ARNs for CodeArtifact repositories to which this policy should have access | <pre>object({<br/>    pull         = set(string)<br/>    push         = set(string)<br/>    pull_through = set(string)<br/>  })</pre> | <pre>{<br/>  "pull": [],<br/>  "pull_through": [],<br/>  "push": []<br/>}</pre> | no |
| <a name="input_iam_attachments"></a> [iam\_attachments](#input\_iam\_attachments) | IAM policy ARNs or JSON IAM policy documents to include in this PermissionSet | `set(string)` | `[]` | no |
| <a name="input_instance_arn"></a> [instance\_arn](#input\_instance\_arn) | The Amazon Resource Name (ARN) of the SSO Instance | `string` | n/a | yes |
| <a name="input_session_duration"></a> [session\_duration](#input\_session\_duration) | The length of time that the application user sessions are valid for | `string` | `"PT1H"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Key-value map of tags for the permission set | `map(string)` | `{}` | no |
| <a name="input_tenant_pretty_name"></a> [tenant\_pretty\_name](#input\_tenant\_pretty\_name) | The properly capitalized, human-readable name we use for this tenant. Used for naming and description. Example: `Data-Platform` | `string` | n/a | yes |
| <a name="input_tenant_subgroup_name"></a> [tenant\_subgroup\_name](#input\_tenant\_subgroup\_name) | The subgroup for the tenant. Typically `Dev` or `DevSecOps` | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_permission_set_arn"></a> [permission\_set\_arn](#output\_permission\_set\_arn) | The ARN of the created permission set. |
<!-- END_TF_DOCS -->