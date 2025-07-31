include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

locals {
  suffix = include.gitlab_config.locals.suffix
}

terraform {
  source = "${get_repo_root()}/../modules//rds"
}

dependency "vpc" {
  config_path = "../../../admin_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cluster" {
  config_path = "../.."
  mock_outputs = {
    cluster_name = ""
    node_groups  = { "node-group" = { security_group_id = "" } }
  }
}

inputs = {
  db_cluster_identifier = "gitlab-server-${local.suffix}"
  cluster_db_name       = "gitlabhq_production"
  master_username       = "gitlab"
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  min_capacity          = 0.0
  max_capacity          = 10.0
  security_group_rules = {
    "eks_ingress" = {
      source_security_group_id = values(dependency.cluster.outputs.node_groups)[0].security_group_id
    }
  }
  manage_master_user_password_rotation = false
}