variable "alias" {
  description = "Key alias"
  type        = string
  validation {
    condition     = length(var.alias) > 3 && !(startswith(var.alias, "alias/") || startswith(var.alias, "/") || endswith(var.alias, "/"))
    error_message = "Alias must have a length and not start with alias/"
  }
}

variable "description" {
  description = "Key description (human readable name)"
  type        = string
  validation {
    condition     = length(var.description) > 10
    error_message = "Description must have a length and be informative"
  }
}

variable "policy_stanzas" {
  description = "Stanzas to add to the key policy"
  # NB: 'sid' is omitted and will be derived from the key.
  # NB: 'resources' is omitted and will be generated internally.
  # NB: 'effect' is omitted and defaulted to 'Allow'. Permitting 'Deny' effects for KMS key policies risks creating
  #     immortal, unmanageable keys that can only be removed by deleting the AWS account which contains them.
  type = map(object({
    conditions = optional(list(object({
      test     = string
      values   = list(string)
      variable = string
    })), [])
    actions    = set(string)
    principals = map(set(string)) # E.g. "AWS" = ["arn:aws:iam:foobar"]
  }))
  validation {
    condition     = alltrue([for p in values(var.policy_stanzas) : !contains(p.actions, "kms:*")])
    error_message = "'kms:*' actions are not allowed; they are risky and can generate security compliance findings"
  }
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}