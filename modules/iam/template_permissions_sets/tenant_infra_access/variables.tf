variable "tenant_pretty_name" {
  description = "The properly capitalized, human-readable name we use for this tenant. Used for naming and description. Example: `Data-Platform`"
  type        = string
}

variable "tenant_subgroup_name" {
  description = "The subgroup for the tenant. Typically `Dev` or `DevSecOps`"
  type        = string
}

variable "instance_arn" {
  description = "The Amazon Resource Name (ARN) of the SSO Instance"
  type        = string
}

variable "session_duration" {
  description = "The length of time that the application user sessions are valid for"
  type        = string
  default     = "PT1H"
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}

variable "iam_attachments" {
  description = "IAM policy ARNs or JSON IAM policy documents to include in this PermissionSet"
  type        = set(string)
  default     = []
  validation {
    condition     = alltrue([for a in var.iam_attachments : startswith(a, "/") || can(jsondecode(a))])
    error_message = "Attachments must either be JSON documents or IAM policy paths starting with '/"
  }
}

variable "allow_code_artifact_repositories" {
  description = "ARNs for CodeArtifact repositories to which this policy should have access"
  type = object({
    pull         = set(string)
    push         = set(string)
    pull_through = set(string)
  })
  default = {
    pull         = []
    push         = []
    pull_through = []
  }
}
