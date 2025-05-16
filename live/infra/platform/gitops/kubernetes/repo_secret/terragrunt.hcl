include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  name      = "infra/platform/gitops/kubernetes"
  user_key  = "user"
  token_key = "key"
}

terraform {
  source = "${get_repo_root()}/../modules//secret"
}

inputs = {
  # This is just an example of the schema/initial value. The content of the secret will be managed externally by
  # Platform engineering staff.
  value = jsonencode(
    {
      (local.user_key)  = "placeholder_1"
      (local.token_key) = "placeholder_2"
    }
  )
  name                           = local.name
  description                    = "Secrets used by ArgoCD to retrieve Kubernetes GitOps repo"
  ignore_changes_to_secret_value = true
}
