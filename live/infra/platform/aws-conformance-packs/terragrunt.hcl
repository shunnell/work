include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_repo_root()}/../modules//s3"
}

inputs = {
  name_prefix          = null
  globally_unique_name = "dos-cloudcity-conformance-packs"
}
