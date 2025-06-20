include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

terraform {
  source = "${get_repo_root()}/../modules//s3/buckets"
}

inputs = {
  globally_unique_names = include.gitlab_config.locals.bucket_names
  name_prefixes         = []
  record_history        = false
  policy_stanzas = {
    gitlab_access = {
      actions = ["s3:*"]
      principals = {
        AWS = [
          "arn:aws:iam::381492150796:role/SSM_access"
        ]
      }
    }
  }
}
