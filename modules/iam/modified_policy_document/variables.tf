variable "require_effect" {
  description = "If non-null, require all statements in the policy to have the same 'effect'"
  type        = string
  nullable    = true
  validation {
    condition     = contains(["allow", "deny"], lower(coalesce(var.require_effect, "deny")))
    error_message = "Must be 'allow' or 'deny', case-insensitive"
  }
}

variable "policies" {
  description = "Set of policy JSON documents to combine, transform, and validate into a single output policy"
  type        = set(string)
  validation {
    condition     = length(var.policies) > 0
    error_message = "At least one policy document must be supplied"
  }
}

variable "require_sid" {
  description = "If true, require all statements in 'policies' to have a 'Sid' key."
  type        = bool
  default     = true
}

variable "max_length" {
  description = "Require the output policy's minified JSON to be shorter than this value"
  type        = number
  validation {
    condition     = var.max_length > 0
    error_message = "max_length must be positive"
  }
  default = 16000 # The max allowed length of any type of AWS policy document
}

# At present, the only "mutator" supported by this module is adding a condition to everything, but more can be added
# as the need arises!
variable "add_conditions_to_all_stanzas" {
  description = "Conditions to append to all 'statement's in 'policies'"
  type = list(object({
    test     = string
    variable = string
    values   = set(string)
  }))
  default = []
}