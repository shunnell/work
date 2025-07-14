include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/../modules//eks/bootstrap"
}

dependency "cluster" {
  config_path = "../"
  mock_outputs = {
    cluster_name = ""
    node_groups = {
      "dummy-nodegroup" = { security_group_id = "" }
    }
  }
}

dependency "vpc" {
  config_path = "../../dev_vpc/vpc"
  mock_outputs = {
    vpc_id = ""
  }
}

inputs = {
  cluster_name                = dependency.cluster.outputs.cluster_name
  vpc_id                      = dependency.vpc.outputs.vpc_id
  nodegroup_security_group_id = values(dependency.cluster.outputs.node_groups)[0].security_group_id
  account_name                = local.account_locals.account
}
