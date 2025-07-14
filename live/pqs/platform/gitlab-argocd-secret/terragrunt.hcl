include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//secret"
}

inputs = {
  value = jsonencode({
    "example-runner-fleet-name" = { token = "glrt-token_goes_here" }
  })
  name                           = "gitlab/cloud-city/platform/gitops/kubernetes"
  description                    = "Secrets used by EKS"
  ignore_changes_to_secret_value = true
}

# TODO : to be removed
