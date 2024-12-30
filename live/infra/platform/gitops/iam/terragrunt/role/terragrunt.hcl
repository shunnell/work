include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/iam//role/"
}

dependency "terragrunter_policy" {
  config_path = "../policy"
  mock_outputs = {
    policy_arn = "arn:aws:iam::381492150796:policy/terragrunter"
  }
}

dependency "terragrunt_user" {
  config_path = "../user"
  mock_outputs = {
    user_arn = "arn:aws:iam::381492150796:user/terragrunt"
  }
}

inputs = {
  role_name  = "terragrunter"
  role_json  = replace(file("iam_role_terragrunter.json"), "USER_ARN", dependency.terragrunt_user.outputs.user_arn)
  policy_arn = dependency.terragrunter_policy.outputs.policy_arn
}
