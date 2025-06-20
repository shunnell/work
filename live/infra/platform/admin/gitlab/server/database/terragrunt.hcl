include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

locals {
  node_group_name = "sandbox-general"
  suffix          = include.gitlab_config.locals.suffix
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

## TODO: Change this to the actual cluster
dependency "cluster" {
  config_path = "../../../sandbox"
  mock_outputs = {
    cluster_name = "dummy-cluster"
    node_groups  = { (local.node_group_name) = { security_group_id = "" } }
  }
}

inputs = {
  db_cluster_identifier = "gitlab-server-${local.suffix}"
  cluster_db_name       = "gitlabhq_production"
  master_username       = "gitlab"
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  security_group_rules = {
    "eks_ingress" = {
      source_security_group_id = dependency.cluster.outputs.node_groups[local.node_group_name].security_group_id
    }
  }
}