include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "sso_resource" {
  path = "${get_path_to_repo_root()}/management/platform/sso/utilities/sso_resource.hcl"
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam/sso/application_assignment"
}

dependency "vpn_application" {
  config_path = "${get_path_to_repo_root()}/management/platform/sso/applications/vpn"
  mock_outputs = {
    application_arn = "arn:aws:sso::111111111111:application/ssoins-1111111111111111/apl-1111111111111111"
  }
}

inputs = {
  group_display_name = "Cloud City Visas Developer Enterprise Users"
  application_arn    = dependency.vpn_application.outputs.application_arn
}