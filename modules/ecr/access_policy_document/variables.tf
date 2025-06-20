variable "repositories" {
  description = "Set of repo names (not ARNs; all repos will be referenced in the infra account)"
  type        = set(string)
  default     = []
  validation {
    condition     = !anytrue([for r in var.repositories : startswith(r, "arn:")])
    error_message = "Supply only repo names, not ARNs"
  }
}

variable "action" {
  description = "'view', 'push', 'delete', or 'pull'"
  type        = string
  validation {
    condition     = contains(["view", "push", "pull", "delete"], var.action)
    error_message = "Must be one of 'view', 'push', 'delete', or 'pull'"
  }
}

variable "principals" {
  type    = set(string)
  default = []
}

variable "conditions" {
  type = list(object({
    test     = string
    variable = string
    values   = set(string)
  }))
  default = []
}