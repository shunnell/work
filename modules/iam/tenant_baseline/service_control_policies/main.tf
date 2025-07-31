data "aws_organizations_organization" "current" {}

locals {
  apply_to_targets = data.aws_organizations_organization.current.roots[*].id
  # apply_to_targets = ["730335639457", "976193220746"]  -- commented for testing targeted applies to specific accounts.
  platform_administrative_arns = [
    # Exclude humans in the Cloud_City_Admin group from tenant SCPs:
    "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/AWSReservedSSO_Cloud_City_Admin*",
    # Exclude terragrunter
    "arn:aws:iam::*:role/terragrunter"
  ]
}

module "fragments" {
  source = "../../fragments"
}

module "all_principals_scp" {
  source                              = "../../organizations_policy"
  description                         = "Restrict all access (tenants and administrators) to disallowed resources"
  name                                = "CloudCity/AllPrincipalsRestrictions"
  organizational_units_or_account_ids = local.apply_to_targets
  policies = [
    module.fragments.iam_restrictions,
    module.fragments.disabled_services_restrictions,
    module.fragments.kms_decrypt_restrictions,
  ]
}

# Tenant SCPs are broken into multiple parts to get around length limits:
module "tenant_scp_1" {
  source                              = "../../organizations_policy"
  description                         = "Restrict tenant access to sensitive resources"
  name                                = "CloudCity/TenantRestrictions/EC2"
  organizational_units_or_account_ids = local.apply_to_targets
  policies                            = [module.fragments.tenant_ec2_restrictions]
  bypass_for_principal_arns           = local.platform_administrative_arns
}

module "tenant_scp_2" {
  source                              = "../../organizations_policy"
  description                         = "Restrict tenant access to sensitive resources"
  name                                = "CloudCity/TenantRestrictions/IAM_EKS_Security"
  organizational_units_or_account_ids = local.apply_to_targets
  policies = [
    module.fragments.tenant_eks_restrictions,
    module.fragments.tenant_security_restrictions,
    module.fragments.tenant_iam_restrictions,
  ]
  bypass_for_principal_arns = local.platform_administrative_arns
}
