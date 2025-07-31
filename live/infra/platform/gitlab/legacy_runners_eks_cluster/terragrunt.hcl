include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "cluster" {
  path = "${get_repo_root()}/_envcommon/platform/eks/cluster.hcl"
}

dependency "vpc" {
  config_path = "../../network/gitlab_vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

inputs = {
  cluster_name = "gitlab"
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnet_ids   = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  node_groups = {
    "gitlab-runners" = {
      size             = 8
      instance_type    = "t3.2xlarge"
      xvdb_volume_size = 50
    }
  }
}
