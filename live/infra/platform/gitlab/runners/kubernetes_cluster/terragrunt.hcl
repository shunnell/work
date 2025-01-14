include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."
}

inputs = {
  runner_eks_cluster_name = "dos_gitlab_central_runner_cluster"
}
