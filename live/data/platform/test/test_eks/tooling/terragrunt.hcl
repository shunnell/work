include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

include "cluster_tooling" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/cluster_tooling.hcl"
}

locals {
  vpn_vars = read_terragrunt_config("${get_path_to_repo_root()}/infra/platform/vpn/vpn_vars.hcl").locals
  vpc_vars = read_terragrunt_config("../../test_vpc/test_vpc.hcl").locals
}

inputs = {
  allowed_cidr_blocks = [
    local.vpn_vars.vpn_cidr_block,
    local.vpc_vars.vpc_cidr_block
  ]
}
