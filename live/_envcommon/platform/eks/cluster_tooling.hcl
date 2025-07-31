locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/../modules//eks/tooling"
}

dependency "cluster" {
  config_path = "../"
  mock_outputs = {
    cluster_name                  = ""
    shared_node_security_group_id = ""
    vpc_id                        = ""
  }
}

dependency "bootstrap" {
  config_path = "../bootstrap"
  mock_outputs = {
    argocd_namespace            = ""
    argocd_service_account_name = ""
    argocd_domain_name          = ""
    root_domain_name            = ""
    root_ca_arn                 = ""
  }
}

inputs = {
  cluster_name                = dependency.cluster.outputs.cluster_name
  vpc_id                      = dependency.cluster.outputs.vpc_id
  nodegroup_security_group_id = dependency.cluster.outputs.shared_node_security_group_id
  argocd_namespace            = dependency.bootstrap.outputs.argocd_namespace
  aws_ecr_service_account     = dependency.bootstrap.outputs.argocd_service_account_name
  argocd_domain_name          = dependency.bootstrap.outputs.argocd_domain_name
  root_domain_name            = dependency.bootstrap.outputs.root_domain_name
  root_ca_arn                 = dependency.bootstrap.outputs.root_ca_arn
}
