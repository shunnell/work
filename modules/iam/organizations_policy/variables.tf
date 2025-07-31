variable "name" {
  description = "The name of the SCP/RCP"
  type        = string
}

variable "description" {
  description = "Description of the SCP/RCP"
  type        = string
}

variable "service_control_policy" {
  description = "If true, create a service control policy. If false, create a resource control policy."
  type        = bool
  default     = true
}

variable "bypass_for_principal_arns" {
  description = "Set of ARNs to *not* apply the policy for."
  type        = set(string)
  default     = []
}

variable "policies" {
  description = "Set of policy documents to combine into this SCP/RCP. All statements in 'policies' must have 'Deny' effects."
  type        = set(string)
  validation {
    condition     = length(var.policies) > 0
    error_message = "At least one policy is required"
  }
}

variable "organizational_units_or_account_ids" {
  description = "Set of organizational unit (OU) IDs or AWS account IDs to apply this SCP/RCP to."
  type        = set(string)
}

variable "tags" {
  description = "Tags to apply to all AWS resources"
  type        = map(string)
  default     = {}
}