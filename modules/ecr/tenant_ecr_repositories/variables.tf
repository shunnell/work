variable "tenant_name" {
  type        = string
  description = "Name of the tenant, lower case, e.g. 'opr'"
  validation {
    condition     = trim(lower(var.tenant_name), " ") == var.tenant_name
    error_message = "Tenant name must be lower case"
  }
}

variable "pull_through_configurations" {
  description = "Map of pull-through prefix to secret ARN used for authenticating to the upstream (or null, for no secret). If a key is omitted from this variable, that pull-through cache rule will not be created for this tenant."
  type        = map(string)
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.pull_through_configurations) : can(local.pull_through_prefix_to_uri[k])])
    error_message = "All keys must match one of the known pull through upstreams in 'local.pull_through_prefix_to_uri'"
  }
  validation {
    condition     = alltrue([for v in values(var.pull_through_configurations) : (v == null || can(regex("^arn:aws:secretsmanager:\\S+:\\d{12}:secret:ecr-pullthroughcache/.+$", v)))])
    error_message = "Keys must either be null or a secretsmanager secret ARN for a secret whose name starts with 'ecr-pullthroughcache/'"
  }
}

variable "aws_accounts_with_pull_access" {
  type        = set(string)
  description = "List of AWS accounts that will be given pull access to this tenant's images"
}

variable "legacy_ecr_repository_names_to_be_migrated" {
  description = "Legacy ECR repository names which will be created/managed by this module. This list should not be added to, and should be replaced with tenants pushing images into '$tenant_name/internal/$repo' over time so that this variable can be removed."
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for r in var.legacy_ecr_repository_names_to_be_migrated : (length(r) > 0 && !endswith(r, "/") && !strcontains(r, "*"))])
    error_message = "Values must be repository names and must not contain wildcards"
  }
}

variable "tags" {
  description = "Tags to apply to AWS resources"
  type        = map(string)
  default     = {}
}
