include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//secret"
}

inputs = {
  # This is just an example of the schema/initial value. The content of the secret will be managed externally by
  # Platform engineering staff.
  value = jsonencode({
    "example-runner-fleet-name" = { token = "glrt-token_goes_here" }
  })
  name                           = "cloudcity-gitlab-secrets"
  description                    = "Secrets used by Cloud City gitlab; only accessible by Platform team IaC"
  ignore_changes_to_secret_value = true
}