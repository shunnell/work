output "ecr_repository_uri" {
  description = "URI of the ECR repository managed by this module (which exists regardless), without https:// prefix. This output blocks on full configuration of that repo, for convenience of terraform/terragrunt dependency management."
  value       = "${data.aws_caller_identity.ecr_account.account_id}.dkr.ecr.${data.aws_region.ecr_region.region}.amazonaws.com"
}

output "pull_through_configurations" {
  description = "Map of pull-through prefix to secret ARN used for authenticating to the upstream (or null, for no secret)."
  value       = { for k, v in local.pull_through_prefix_to_secret_name : k => (v == null ? v : module.pull_through_secrets[v].secret_arn) }
}
