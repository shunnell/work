include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "cluster" {
  path = "${get_repo_root()}/_envcommon/platform/eks/cluster.hcl"
  # NB: IVA is special in this regard in that they add several additional CIDRs to their cluster for remote access from
  # GitLab and elsewhere, so we use the "deep" merge strategy to append those here.
  merge_strategy = "deep"
}

dependency "vpc" {
  config_path = "../dev_vpc/vpc"
  mock_outputs = {
    vpc_id                = ""
    private_subnets_by_az = {}
  }
}

inputs = {
  cluster_name = "managed-dev-eks"

  # IVA self-serve updated their cluster at some point, so it's on 1.33 even though others are not as of this writing:
  kubernetes_version = "1.33"

  vpc_id     = dependency.vpc.outputs.vpc_id
  subnet_ids = values(dependency.vpc.outputs.private_subnets_by_az)[*].subnet_id

  # Extra CIDRs added at IVA's request:
  kubernetes_control_plane_allowed_cidrs = [
    dependency.vpn_vpc.outputs.vpc_cidr_block,
    "172.16.0.0/16",
    "192.168.247.0/24"
  ]

  node_groups = {
    general = {
      instance_type = "m5.2xlarge",
      size          = 3
    }
  }
}

