# `local_role_data`

This module manages no resources, and exists to read account-local state and produce outputs corresponding to various
SSO roles and IaC roles in use in a given account.

The intended use of this module is for IAM policies/access control documents that need specifically named principals
(rather than, say, wildcarded ones) for various purposes--specific `"AWS"` principals, cross-account principal identification,
and the like. In those cases, the ARNs of the AWS SSO-created roles are not predictable, nor can they be discovered
via the output of management-account IAM resources (e.g. permission set attachments). To cope with that, this module
is offered as a convenient place to identify SSO (and eventually IaC) roles by canonical name.

**This module generally should not be used from other code in `modules`. Instead, it should be instantiated once per 
account in `live` and passed around as a Terragrunt `dependency`.** Doing this minimizes redundant/slow data variable
fetching.

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
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_role.terragrunter](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_role) | data source |
| [aws_iam_roles.sso_roles](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_roles) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_account_id"></a> [account\_id](#output\_account\_id) | Current AWS account ID (offered as a convenient, to save code; many things that use this module will also want the account ID) |
| <a name="output_iac_role_arns_by_tenant_name"></a> [iac\_role\_arns\_by\_tenant\_name](#output\_iac\_role\_arns\_by\_tenant\_name) | Mapping of tenant name to role ARNs used specifically for IaC (e.g. cross account Terraform). These roles should never be assumed by or assigned to human users, via SSO or otherwise. A special key, 'current', is included and represents the current IaC role running terraform. |
| <a name="output_most_privileged_users"></a> [most\_privileged\_users](#output\_most\_privileged\_users) | List of IAM principal ARNs of the highest-permissioned users in Cloud City. Should not be referenced in most ordinary code. For use in IaC code that needs to express e.g. 'god users need to be able to access some resource, regardless of other IAM filtering we perform'. This helps prevent e.g. creating 'immortal' AWS resources that cannot be managed/deleted at all due to required resource-based policies. |
| <a name="output_sso_role_arns_by_permissionset_name"></a> [sso\_role\_arns\_by\_permissionset\_name](#output\_sso\_role\_arns\_by\_permissionset\_name) | Mapping of IAMIC SSO-generated role (e.g. 'Cloud\_City\_Admin' or 'Sandbox\_Dev') to account-local role ARNs. |
<!-- END_TF_DOCS -->