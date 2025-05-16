include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  node_group_name = "sandbox-general"
}

dependency "vpc" {
  config_path = "../../admin_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cluster" {
  config_path = "../../sandbox"
  mock_outputs = {
    cluster_name = ""
    node_groups = {
      (local.node_group_name) = { security_group_id = "sg-123" }
    }
  }
}

terraform {
  source = "${get_repo_root()}/../modules//rds"
}

inputs = {
  db_cluster_identifier = "nexus-repo"
  master_username       = "nexus"
  cluster_db_name       = "nexus"
  inbound_security_group_ids = {
    "${local.node_group_name} node group" = dependency.cluster.outputs.node_groups[local.node_group_name].security_group_id
  }
  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
}
