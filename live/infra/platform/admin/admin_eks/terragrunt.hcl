include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  admin_vars        = read_terragrunt_config(find_in_parent_folders("admin.hcl")).locals
  common_identifier = local.admin_vars.common_identifier
  cluster_name      = local.common_identifier

  vpn_vars       = read_terragrunt_config("../../vpn/vpn_vars.hcl").locals
  vpn_cidr_block = local.vpn_vars.vpn_cidr_block
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

dependency "vpc" {
  config_path = "../admin_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/eks"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
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

  node_groups = {
    "${local.cluster_name}" = {
      size = 3
      # instance_type = "m7a.4xlarge"
      security_group_rules = {
        "VPN access" = {
          type   = "ingress"
          ports  = [443]
          target = local.vpn_cidr_block
        }
      }
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
