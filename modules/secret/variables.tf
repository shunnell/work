variable "name" {
  description = "Name of the secret."
  type        = string
  nullable    = true
  default     = null
  validation {
    condition     = (var.name == null) != (var.name_prefix == null)
    error_message = "One and only one of 'name' or 'name_prefix' must be specified."
  }
}

variable "name_prefix" {
  description = "Name prefix for the secret. Mutually exclusive with 'name'."
  type        = string
  nullable    = true
  default     = null
}

variable "description" {
  description = "Description of the secret."
  type        = string
}

variable "value" {
  description = "The secret."
  type        = string
  sensitive   = true
}

variable "ignore_changes_to_secret_value" {
  type        = bool
  description = "If true, changes to the secret value in Terraform will be ignored after initial secret creation (assuming that the secret will be modified externally)"
  default     = false
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
