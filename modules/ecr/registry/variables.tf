variable "aws_accounts_enabled_for_pull_through" {
  type        = set(string)
  description = "List of AWS accounts that can issue pull-through requests for per-tenant pullthrough images. Note: A tenant can only issue pull-through requests to an account if it is listed here *and* if an instance of 'tenant_ecr_repositories' is present for that tenant, with this same account listed in 'tenant_ecr_repositories.aws_accounts_with_pull_access'."
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
