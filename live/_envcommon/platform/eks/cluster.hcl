dependency "cloudwatch_sharing_target" {
  config_path = "${get_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/eks"
  mock_outputs = {
    cloudwatch_destination_arn = ""
  }
}

dependency "cloud_city_roles" {
  config_path = find_in_parent_folders("platform/common/account")
  mock_outputs = {
    most_privileged_users               = []
    sso_role_arns_by_permissionset_name = { "Sandbox_Dev" = "" }
  }
}

dependency "vpn_vpc" {
  config_path = "${get_repo_root()}/infra/platform/network/vpn_vpc"
  mock_outputs = {
    vpc_cidr_block = ""
  }
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

inputs = {
  administrator_role_arns = compact(concat(
    dependency.cloud_city_roles.outputs.most_privileged_users,
    # Not every account has sandbox-dev access (e.g. production, infra):
    [lookup(dependency.cloud_city_roles.outputs.sso_role_arns_by_permissionset_name, "Sandbox_Dev", null)]
  ))
  node_groups = {
    general = {
      size = 3
    }
  }
  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  kubernetes_control_plane_allowed_cidrs  = [dependency.vpn_vpc.outputs.vpc_cidr_block]
}
