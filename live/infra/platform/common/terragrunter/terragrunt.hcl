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
  config_path = "../../cloud_city_roles"
  mock_outputs = {
    sso_role_arns_by_permissionset_name = {
      Cloud_City_Admin = "arn"
    }
  }
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//common/terragrunter/"
}

inputs = {
  iac_account_id = local.account_id
  additional_role_assumers = [
    # Let human engineers on the platform team with the Cloud_City_Admin permission set assume terragrunter. This is
    # how IaC is applied by developers manually:
    dependency.cloud_city_roles.outputs.sso_role_arns_by_permissionset_name["Cloud_City_Admin"],
    # Let the IAM role of the GitLab runner cluster for the Platform team's gitlab runners assume terragrunter:
    # predictably generated, ../../gitlab/runners/platform_runner_fleet
    # TODO : get role if exists - so that this can be applied whenever the role hasn't been created yet
    "arn:aws:iam::${local.account_id}:role/gitlab-runners-06ae818af9d6db84f2067d19f010d9ee"
  ]
}
