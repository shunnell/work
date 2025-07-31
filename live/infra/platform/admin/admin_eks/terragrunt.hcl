include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "cluster" {
  path = "${get_repo_root()}/_envcommon/platform/eks/cluster.hcl"
}

dependency "vpc" {
  config_path = "../admin_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

inputs = {
  cluster_name = read_terragrunt_config(find_in_parent_folders("admin.hcl")).locals.common_identifier
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnet_ids   = [for _, v in dependency.vpc.outputs.private_subnets_by_az : v.subnet_id]

  node_groups = {
    general = {
      instance_type = "c6a.2xlarge"
      size          = 3
    }
  }
}
