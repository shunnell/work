include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "vpc" {
  config_path = "../prod_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

include "cluster" {
  path = "${get_repo_root()}/_envcommon/platform/eks/cluster.hcl"
}

inputs = {
  cluster_name            = "production"
  vpc_id                  = dependency.vpc.outputs.vpc_id
  subnet_ids              = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  administrator_role_arns = dependency.cloud_city_roles.outputs.most_privileged_users,
  node_groups = {
    general = {
      size = 1
      # Instance type recommended by OPR3 for prod, to be representative/similar to instances used in their sandbox
      # environments. Can be reassessed/changed/standardized as needed:
      instance_type = "m5.xlarge"
    }
  }
}
