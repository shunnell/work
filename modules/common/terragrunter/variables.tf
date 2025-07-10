variable "iac_account_id" {
  description = "AWS Account ID of the account that manages IaC and should be able to assume 'terragrunter' in other accounts"
  type        = string
  nullable    = true
}

variable "additional_role_assumers" {
  description = "Additional principals that should be allowed to assume the terragrunter role"
  type        = list(string)
  default     = []
}

variable "terragrunter_role_additional_policies" {
  description = "Additional policies ARNs to apply to the Terragrunter Role"
  type        = list(string)
  default     = []
}

variable "condition_trust_policy" {
  description = "Condition to apply to the trust policy"
  type = list(object({
    test     = string
    variable = string
    values   = list(string)
  }))
  default = []
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
