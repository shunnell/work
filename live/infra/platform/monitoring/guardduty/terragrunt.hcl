include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//monitoring/guardduty"
}

inputs = {
  eks_tag_key       = "eks:cluster-name"
  ssm_document_name = "EnableGuardDutyRuntimeAgent"
}
