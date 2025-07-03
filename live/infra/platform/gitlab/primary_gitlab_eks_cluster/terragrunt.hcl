include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../../network/gitlab_vpc"
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

dependency "cloud_city_roles" {
  config_path = "../../common/account"
  mock_outputs = {
    most_privileged_users = []
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
  cluster_name            = "gitlab-primary"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]
  administrator_role_arns = dependency.cloud_city_roles.outputs.most_privileged_users
  node_groups = {
    "gitlab-server" = {
      size             = 6
      volume_size      = 50
      xvdb_volume_size = 100
      instance_type    = "c6a.4xlarge"
      security_group_rules = {
        "VPN access" = {
          type   = "ingress"
          ports  = [443]
          target = dependency.vpn_vpc.outputs.vpc_cidr_block
        }
      }
    }
  }

  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn

  cluster_security_group_rules = {
    "VPN access" = {
      type   = "ingress"
      ports  = [443]
      target = dependency.vpn_vpc.outputs.vpc_cidr_block
    }
  }
}
