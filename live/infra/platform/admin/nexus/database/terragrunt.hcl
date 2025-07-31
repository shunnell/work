include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "nexus_config" {
  path   = find_in_parent_folders("nexus_config.hcl")
  expose = true
}

locals {
  suffix = include.nexus_config.locals.suffix
}

terraform {
  source = "${get_repo_root()}/../modules//rds"
}

dependency "vpc" {
  config_path = "../../admin_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cluster" {
  config_path = "../../admin_eks"
  mock_outputs = {
    cluster_name                  = ""
    shared_node_security_group_id = ""
  }
}


inputs = {
  db_cluster_identifier = "nexusrepo${local.suffix}"
  cluster_db_name       = "nexus"
  master_username       = "nexus"
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  min_capacity          = 0.5
  max_capacity          = 10
  security_group_rules = {
    "eks_ingress" = {
      source_security_group_id = dependency.cluster.outputs.shared_node_security_group_id
    }
  }
  manage_master_user_password_rotation = false
}
