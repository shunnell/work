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
  cluster_name = "gitlab-primary"
  vpc_id       = dependency.vpc.outputs.vpc_id
  subnet_ids   = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id
  node_groups = {
    "gitlab-server" = {
      size             = 3
      volume_size      = 50
      xvdb_volume_size = 100
      instance_type    = "c6a.4xlarge"
    }
  }
}
