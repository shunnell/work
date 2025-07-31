include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_name = "one"

  vpn_vars       = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals
  vpn_cidr_block = local.vpn_vars.vpn_cidr_block
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

dependency "vpc" {
  config_path = "../vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/eks"
  mock_outputs = {
    cloudwatch_destination_arn = ""
  }
}

dependency "cloud_city_roles" {
  config_path = "../../common/account"
  mock_outputs = {
    most_privileged_users = []
  }
}

inputs = {
  cluster_name            = local.cluster_name
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  administrator_role_arns = dependency.cloud_city_roles.outputs.most_privileged_users
  ingress_targets = {
    "VPN access" = local.vpn_cidr_block
  }

  node_groups = {
    "${local.cluster_name}" = {
      size = 3
      # security_group_rules = {
      #   "VPN access" = {
      #     type   = "ingress"
      #     ports  = [443]
      #     target = local.vpn_cidr_block
      #   }
      # }
    }
  }

  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn

  cluster_security_group_rules = {
    "VPN access" = {
      type   = "ingress"
      ports  = [443]
      target = local.vpn_cidr_block
    }
  }
}
