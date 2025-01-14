variable "role_name" {
  description = "Name of the IAM role"
  type        = string
}

variable "role_json" {
  description = "The raw IAM role json"
  type        = string
}

variable "policy_arns" {
  description = "The associated IAM policy(ies) to attach"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
