include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

locals {
  account_locals = read_terragrunt_config(find_in_parent_folders("account.hcl")).locals
  repo_secret    = read_terragrunt_config("${get_repo_root()}/infra/platform/gitops/kubernetes/repo_secret/terragrunt.hcl").locals
}

terraform {
  source = "${get_repo_root()}/../modules//eks/ccp_kubernetes_repo"
}

dependency "cluster" {
  config_path = "../"
  mock_outputs = {
    cluster_name = "name"
  }
}

inputs = {
  cluster_name              = dependency.cluster.outputs.cluster_name
  k8s_repo_secret_name      = local.repo_secret.name
  k8s_repo_secret_user_key  = local.repo_secret.user_key
  k8s_repo_secret_token_key = local.repo_secret.token_key
  config_path               = "infra/sandbox"
}
