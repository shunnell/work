variable "secret_name" {
  description = "Name of the secret."
  type        = string
}

variable "secret_value" {
  description = "The secret."
  type        = string
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
