include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  cluster_name = "dev-eks-1"
}

terraform {
  source = "${get_repo_root()}/../modules//eks/cluster"
}

dependency "vpc" {
  config_path = "../dev_vpc/vpc"
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
    most_privileged_users               = []
    sso_role_arns_by_permissionset_name = { "Sandbox_Dev" = "" }
  }
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
    "${local.cluster_name}-1" = {
      size = 3
      security_group_rules = {
        "VPN access" = {
          type   = "ingress"
          ports  = [443]
          target = "172.40.0.0/16"
        }
      }
    }
  }

  cloudwatch_log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn

  cluster_security_group_rules = {
    "VPN access" = {
      type   = "ingress"
      ports  = [443]
      target = "172.40.0.0/16"
    }
  }
}
