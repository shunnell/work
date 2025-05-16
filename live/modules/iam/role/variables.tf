variable "role_name" {
  description = "Name of the IAM role (one of role_name or role_name_prefix must be set)"
  type        = string
  nullable    = true
  default     = null
  # NB: validation is done in a resource lifecycle condition
}

variable "role_name_prefix" {
  description = "Name of the IAM role  (one of role_name or role_name_prefix must be set)"
  type        = string
  nullable    = true
  default     = null
  # NB: validation is done in a resource lifecycle condition
}

variable "description" {
  description = "Human-readable description of the IAM role"
  type        = string
  default     = ""
}

variable "trust_policy_json" {
  description = "The trust policy of the IAM role; must be a JSON string. Set this if assume_role_principals cannot express the trust policy needed."
  type        = string
  default     = "{}"
  validation {
    # NB: not using 'can' so that errors are surfaced properly:
    condition     = jsondecode(var.trust_policy_json) != null
    error_message = "Must be JSON"
  }
  validation {
    # We could technically allow them both to be set, since we're merging them via data.iam_policy_document, but that
    # gets confusing if allows and denies are both present; it's not worth the flexibility. If a use-case emerges that
    # could benefit from additional shorthand assume policies, the preferable solution would be to expand the
    # assume_role_principals API (e.g. to support federated principals or conditions etc.).
    condition     = (length(jsondecode(var.trust_policy_json)) == 0) != (length(var.assume_role_principals) == 0)
    error_message = "One and only one of 'trust_policy_json' and 'assume_role_principals' must be set."
  }
}

variable "assume_role_principals" {
  description = "Shorthand specification of sts:AssumeRole service or ARN/AWS principals which can assume this role. Info about principals that can assume this role. A set of either service names (ending in .amazonaws.com) or ARNs of 'iam:' or 'sts:' principals that can assume this role. All specified principals will be granted unconditional allow for sts:AssumeRole into this role. If a more specific assume policy is needed (e.g. conditions, denies, string-matches, etc), supply trust_policy_json instead."
  type        = set(string)
  default     = []
  validation {
    condition = alltrue([
      for p in var.assume_role_principals :
      (can(regex(local.service_principal_regex, p)) || can(regex(local.aws_principal_regex, p)))
    ])
    error_message = "All principals must either be AWS service hostnames (e.g. ec2.amazonaws.com) or ARNs. If ARNs are supplied, they must start with 'arn:aws:iam' or 'arn:aws:sts' and contain no wildcards."
  }
}

variable "policy_arns" {
  description = "The associated IAM policy ARNs to attach"
  type        = list(string)
  default     = []
}

variable "policy_json_documents" {
  description = "Map of descriptive policy name to JSON strings of policy documents to create and attach to this role (e.g. the output of data.aws_iam_policy_document.whatever.json)"
  type        = map(string)
  default     = {}
}

variable "permissions_boundary_policy_arn" {
  description = "ARN of an IAM policy to use as a permissions boundary for this role, if any"
  default     = null
  nullable    = true
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}