output "pull_through_cache_rules" {
  description = "Pull through cache rule IDs, keyed by repo prefix (which corresponds to the provider of the upstream)"
  value       = { for upstream in keys(local.pull_through_upstreams) : upstream => aws_ecr_pull_through_cache_rule.rule[upstream].id }
}

output "ecr_repository_uri" {
  description = "URI of the ECR repository managed by this module (which exists regardless), without https:// prefix. This output blocks on full configuration of that repo, for convenience of terraform/terragrunt dependency management."
  value       = "${data.aws_caller_identity.ecr_account.account_id}.dkr.ecr.${data.aws_region.ecr_region.name}.amazonaws.com"
  depends_on  = [module.pull_through_secrets, aws_ecr_repository_creation_template.template, aws_ecr_pull_through_cache_rule.rule]
}
