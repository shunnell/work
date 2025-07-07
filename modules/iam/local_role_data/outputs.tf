locals {
  sso_roles_by_permissionset = { for arn in data.aws_iam_roles.sso_roles.arns : regex(local.sso_role_regex, arn)[0] => arn }
}

output "sso_role_arns_by_permissionset_name" {
  description = "Mapping of IAMIC SSO-generated role (e.g. 'Cloud_City_Admin' or 'Sandbox_Dev') to account-local role ARNs."
  value       = local.sso_roles_by_permissionset
}

output "iac_role_arns_by_tenant_name" {
  description = "Mapping of tenant name to role ARNs used specifically for IaC (e.g. cross account Terraform). These roles should never be assumed by or assigned to human users, via SSO or otherwise. A special key, 'current', is included and represents the current IaC role running terraform."
  value = {
    # NB: Assumes only one IaC role per tenant. If future design plans change it to multiple IaC roles per tenant per account, this interface should be changed.
    platform = data.aws_iam_role.terragrunter.arn
    current  = data.aws_iam_session_context.current.issuer_arn
  }
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