include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "k8s" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/k8s.hcl"
}

include "bootstrap" {
  path = "${get_path_to_repo_root()}/_envcommon/platform/eks/cluster_bootstrap.hcl"
}

inputs = {
  enable_argocd                       = false
  enable_aws_load_balancer_controller = false
}
