include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//rds"
}

dependency "vpc" {
  config_path = "../../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

dependency "cluster" {
  config_path = "../../eks_cluster"
  mock_outputs = {
    cluster_name = "gitlab"
    node_groups = {
      "dummy-nodegroup" = { security_group_id = "sg-123" }
    }
  }
}


inputs = {
  db_cluster_identifier = "gitlab-server"
  cluster_db_name       = "postgresql"
  master_username       = "gitlab"
  vpc_id                = dependency.vpc.outputs.vpc_id
  subnet_ids            = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
}