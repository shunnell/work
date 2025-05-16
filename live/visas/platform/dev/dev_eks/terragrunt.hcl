include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  vpc_vars = read_terragrunt_config("../dev_vpc/dev_vpc.hcl").locals
  vpn_access_rule = {
    type   = "ingress"
    ports  = [443]
    target = local.vpc_vars.vpn_cidr_block
  }
  cluster_name = "visas-dev"
}

dependency "vpc" {
  config_path = "../dev_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/eks"
  mock_outputs = {
    cloudwatch_destination_arn = ""
  }
}

# TODO this should move to common soon, having it individually instantiated is not great.
dependency "cloud_city_roles" {
  config_path = "./cloud_city_roles"
  mock_outputs = {
    most_privileged_users               = []
    sso_role_arns_by_permissionset_name = { "Sandbox_Dev" = "" }
  }
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

inputs = {
  cluster_name = local.cluster_name
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnet_ids   = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  administrator_role_arns = concat(
    dependency.cloud_city_roles.outputs.most_privileged_users,
    [dependency.cloud_city_roles.outputs.sso_role_arns_by_permissionset_name["Sandbox_Dev"]]
  )

  node_groups = {
    "${local.cluster_name}" = {
      size = 3
      security_group_rules = {
        "VPN access" = local.vpn_access_rule
      }
    }
  }

  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn

  cluster_security_group_rules = {
    "VPN access" = local.vpn_access_rule
  }
}
