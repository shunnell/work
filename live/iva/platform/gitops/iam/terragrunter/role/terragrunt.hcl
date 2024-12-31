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

inputs = {
  role_name  = "terragrunter"
  role_json  = file("${get_path_to_repo_root()}/_envcommon/platform/gitops/iam/terragrunter/iam_role_assume_terragrunter.json")
  policy_arn = dependency.terragrunter_policy.outputs.policy_arn
}
