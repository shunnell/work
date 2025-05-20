variable "tenant_name" {
  type        = string
  description = "Name of the tenant, lower case, e.g. 'opr'"
  validation {
    condition     = trim(lower(var.tenant_name), " ") == var.tenant_name
    error_message = "Tenant name must be lower case"
  }
}

variable "aws_accounts_with_pull_access" {
  type        = set(string)
  default     = []
  description = "List of AWS accounts that will be given pull access to this tenant's images"
}

variable "legacy_ecr_repository_names_to_be_migrated" {
  type        = set(string)
  default     = []
  description = "Legacy ECR repository names which will be created/managed by this module. This list should not be added to, and should be replaced with tenants pushing images into 'cloud-city/$tenant_name/$repo' over time so that this variable can be removed."
}