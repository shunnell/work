/*
This module manages no resources, and exists to read account-local state and produce outputs corresponding to various
SSO roles and IaC roles in use in a given account.

The intended use of this module is for IAM policies/access control documents that need specifically named principals
(rather than, say, wildcarded ones) for various purposes--specific `"AWS"` principals, cross-account principal identification,
and the like. In those cases, the ARNs of the AWS SSO-created roles are not predictable, nor can they be discovered
via the output of management-account IAM resources (e.g. permission set attachments). To cope with that, this module
is offered as a convenient place to identify SSO (and eventually IaC) roles by canonical name.
*/

locals {
  # Example: role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_AWSAdministratorAccess_e2346643e75b96cd
  # The AWS unique-id suffix doesn't have a published length, but it likely will not shrink:
  sso_role_regex = "^arn:aws:iam::\\d{12}:role/aws-reserved/sso[.]amazonaws[.]com/AWSReservedSSO_(\\S+)_[a-z0-9]{10,}$"
  iac_role_regex = "^arn:aws:iam::\\d{12}:role/\\w+$"
  sso_roles_by_permissionset = {
    for arn in data.aws_iam_roles.sso_roles.arns :
    regex(local.sso_role_regex, arn)[0] => arn
  }
}

data "aws_iam_roles" "sso_roles" {
  path_prefix = "/aws-reserved/sso.amazonaws.com/"
}

# TODO we should have a way (tags?) of retrieving an account's available IaC roles, ideally on a per-tenant-name basis.
#   For now, we just do terragrunter because it's the only truly supported IaC role.
data "aws_iam_role" "terragrunter" {
  # Data variable is used to make sure the role actually exists. This is a bit silly in the case of terragrunter, but it's
  # here as a precedent for finding other IaC roles in the future.
  name = "terragrunter"
  lifecycle {
    postcondition {
      condition     = can(regex(local.iac_role_regex, self.arn))
      error_message = "Terragrunter role is assumed (has slashes in its name) and cannot be used as an IAM principal"
    }
  }
}

# See: https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context#find-the-terraform-runners-source-role
data "aws_iam_session_context" "current" {
  arn = data.aws_caller_identity.current.arn
  lifecycle {
    postcondition {
      condition     = can(regex(local.iac_role_regex, self.issuer_arn))
      error_message = "Current session issuer role is assumed (has slashes in its name) and cannot be used as an IAM principal"
    }
  }
}

output "sso_role_arns_by_permissionset_name" {
  description = "Mapping of IAMIC SSO-generated role (e.g. 'Cloud_City_Admin' or 'Sandbox_Dev') to account-local role ARNs."
  value       = local.sso_roles_by_permissionset
}

output "most_privileged_users" {
  description = "List of IAM principal ARNs of the highest-permissioned users in Cloud City. Should not be referenced in most ordinary code. For use in IaC code that needs to express e.g. 'god users need to be able to access some resource, regardless of other IAM filtering we perform'. This helps prevent e.g. creating 'immortal' AWS resources that cannot be managed/deleted at all due to required resource-based policies."
  value = [
    data.aws_iam_role.terragrunter.arn,
    local.sso_roles_by_permissionset["Cloud_City_Admin"],
  ]
}

output "account_id" {
  description = "Current AWS account ID (offered as a convenient, to save code; many things that use this module will also want the account ID)"
  value       = data.aws_caller_identity.current.account_id
}

output "account_principal" {
  description = "The IAM principal representing 'anyone in this account' (i.e. 'root'). Use with caution; granting permission to/fron this principal authorizes any principals in this account, regardless of name."
  value       = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
}