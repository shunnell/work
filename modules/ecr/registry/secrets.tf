module "pull_through_secrets" {
  source                         = "../../secret"
  for_each                       = local.pull_through_secrets
  name                           = "ecr-pullthroughcache/${each.key}"
  description                    = "${each.key} secret for ECR pull-through cache"
  value                          = "<externally/manually set>"
  ignore_changes_to_secret_value = true
}
