include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  name = "cloud-city/platform/sonatype-license-2024-09-20"
}

terraform {
  source = "${get_repo_root()}/../modules//secret"
}

inputs = {
  value = jsonencode(
    {
      "sonatype-license-2024-09-20T172110Z.lic.base64" = ""
    }
  )
  name                           = local.name
  description                    = "Sonatype Nexus license"
  ignore_changes_to_secret_value = true
}
