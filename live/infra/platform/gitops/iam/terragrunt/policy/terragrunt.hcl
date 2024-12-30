include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam//policy/"
}

inputs = {
  policy_name = "terragrunter"
  policy_json = file("iam_policy_terragrunter.json")
}
