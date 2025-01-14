include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/sso_inline_policy"
}

locals {
  sso_vars     = read_terragrunt_config(find_in_parent_folders("sso.hcl"))
  instance_arn = local.sso_vars.locals.instance_arn
  default_tags = local.sso_vars.locals.default_tags
}

dependency "permission_set" {
  config_path = "../permission_set"
  mock_outputs = {
    permission_set_arn = "arn:aws:sso:::permissionSet/ssoins-722334f2d9ffae26/ps-0123456789012345"
  }
}

inputs = {
  permission_set_arn = dependency.permission_set.outputs.permission_set_arn
  instance_arn       = local.instance_arn
  inline_policy      = file("policy.json")
  tags               = local.default_tags
} 