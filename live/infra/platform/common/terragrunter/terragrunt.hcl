include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

locals {
  infra_terragrunter_role_arn = include.account.locals.terragrunter_role_arn
  account_id                  = include.account.locals.account_id
}

dependency "cloud_city_roles" {
  config_path = "../../common/account"
  mock_outputs = {
    sso_role_arns_by_permissionset_name = {
      Cloud_City_Admin = "arn"
    }
  }
}

dependency "platform_runner_roles" {
  config_path = "platform-runner-roles"
  mock_outputs = {
    arns = []
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//common/terragrunter/"
}

inputs = {
  iac_account_id = local.account_id
  condition_trust_policy = [
    {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [include.account.locals.terragrunter_external_id]
    }
  ]
  additional_role_assumers = concat(
    # Let human engineers on the platform team with the Cloud_City_Admin permission set assume terragrunter. This is
    # how IaC is applied by developers manually:
    [dependency.cloud_city_roles.outputs.sso_role_arns_by_permissionset_name["Cloud_City_Admin"]],
    # Let the IAM role of the GitLab runner cluster for the Platform team's gitlab runners assume terragrunter:
    # predictably generated, ../../gitlab/runners/platform_runner_fleet
    dependency.platform_runner_roles.outputs.arns
  )
}
