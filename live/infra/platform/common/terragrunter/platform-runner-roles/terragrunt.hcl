include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "."
}

inputs = {
  role_name = "gitlab-runners-06ae818af9d6db84f2067d19f010d9ee"
}