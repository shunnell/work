# NB: The permissions that allow ECR to perform the pull-through on these paths are controlled in `modules/ecr/registry`
# and are set at the account level, where we add IAM to permit pull-through for all principals in the organization
# at wildcarded paths like "/*/docker/*". Since that accountwide IAM *only* adds the pull-through bits, the other
# access bits (e.g. to authenticate and actually pull the image onto a client) are still required to do anything
resource "aws_ecr_pull_through_cache_rule" "rule" {
  for_each              = var.pull_through_configurations
  ecr_repository_prefix = "${var.tenant_name}/${each.key}"
  upstream_registry_url = local.pull_through_prefix_to_uri[each.key]
  credential_arn        = each.value
  depends_on            = [aws_ecr_repository_creation_template.template]
}
