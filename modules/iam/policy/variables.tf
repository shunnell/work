variable "name_prefix" {
  description = "Name prefix of the IAM policy"
  type        = string
  nullable    = true
  default     = null
  validation {
    condition     = (var.name_prefix == null) != (var.policy_name == null)
    error_message = "One and only one of 'name_prefix' and 'policy_name' must be set."
  }
}

variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
  nullable    = true
  default     = null
}

variable "policy_json" {
  description = "The raw IAM policy json"
  type        = string
}

variable "policy_description" {
  description = "The description of the policy"
  type        = string
  default     = ""
}

# TODO consider defaulting or prepending /cloudcity/
variable "policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = "/"
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
