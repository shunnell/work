include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "gitlab_config" {
  path   = find_in_parent_folders("gitlab_config.hcl")
  expose = true
}

dependency "irsa_role" {
  config_path = "../irsa"
  mock_outputs = {
    iam_role_arn = "arn:aws:iam:::role/mock"
  }
}

locals {
  prefix = include.gitlab_config.locals.prefix
  names = [
    "${local.prefix}-artifacts",
    "${local.prefix}-ci-secure-files",
    "${local.prefix}-dependency-proxy",
    "${local.prefix}-lfs",
    "${local.prefix}-mr-diffs",
    "${local.prefix}-packages",
    "${local.prefix}-pages",
    "${local.prefix}-terraform-state",
    "${local.prefix}-uploads"
  ]
}

terraform {
  source = "${get_repo_root()}/../modules//s3/buckets"
}

inputs = {
  name_prefixes = local.names
  policy_stanzas = {
    gitlab_access = {
      actions = ["s3:*"]
      principals = {
        AWS = [dependency.irsa_role.outputs.iam_role_arn]
      }
    }
  }
}
