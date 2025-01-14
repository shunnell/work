variable "policy_name" {
  description = "Name of the IAM policy"
  type        = string
}

variable "policy_json" {
  description = "The raw IAM policy json"
  type        = string
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "policy_path" {
  description = "Path of the IAM policy"
  type        = string
  default     = "/"
}
