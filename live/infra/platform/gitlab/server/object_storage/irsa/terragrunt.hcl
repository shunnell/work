include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

terraform {
  source = "${get_repo_root()}/../modules//eks/service_account"
}

dependency "cluster" {
  config_path = "../../../eks_cluster"
  mock_outputs = {
    cluster_name      = "name"
    oidc_provider_arn = "aws:mock:oidc/arn"
  }
}

inputs = {
  cluster_name      = dependency.cluster.outputs.cluster_name
  oidc_provider_arn = dependency.cluster.outputs.oidc_provider_arn

  namespace = include.gitlab_config.locals.namespace
  name      = include.gitlab_config.locals.service_account_name
}
