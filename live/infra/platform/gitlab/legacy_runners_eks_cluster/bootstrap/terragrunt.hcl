include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  repo_secret    = read_terragrunt_config("../../../gitops/kubernetes/repo_secret/terragrunt.hcl").locals
  gitlab_config  = read_terragrunt_config(find_in_parent_folders("gitlab_config.hcl")).locals
}

terraform {
  source = "${get_repo_root()}/../modules//eks/bootstrap"
}

dependency "cluster" {
  config_path = "../"
  mock_outputs = {
    cluster_name = "name"
    vpc_id       = ""
    node_groups  = { "gitlab-runners" = { security_group_id = "" } }
  }
}

inputs = {
  cluster_name                        = dependency.cluster.outputs.cluster_name
  vpc_id                              = dependency.cluster.outputs.vpc_id
  nodegroup_security_group_id         = dependency.cluster.outputs.node_groups["gitlab-runners"].security_group_id
  enable_argocd                       = false
  enable_aws_load_balancer_controller = false
  account_name                        = local.account_locals.account

  k8s_repo_secret_name      = local.repo_secret.name
  k8s_repo_secret_user_key  = local.repo_secret.user_key
  k8s_repo_secret_token_key = local.repo_secret.token_key

  namespaces = [local.gitlab_config.namespace]
}
