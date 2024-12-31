include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam//user/"
}

dependency "terragrunter_policy" {
  config_path = "../policy"
  mock_outputs = {
    policy_arn = "arn:aws:iam::381492150796:policy/terragrunter"
  }
}

inputs = {
  policy_arn = dependency.terragrunter_policy.outputs.policy_arn
  user_name  = "terragrunt"
}
