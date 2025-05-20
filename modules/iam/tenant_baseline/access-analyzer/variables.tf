# Defined in variables.tf
variable "analyzer_name" {
  description = "The name of the organization external access analyzer."
  type        = string
  default     = "cloudcity-access-analyzer"
}

variable "analyzer_type" {
  description = "analyzer type should be specified"
  type        = string
  default     = "ACCOUNT"
}

variable "tags" {
  description = "Tags to apply to the resource"
  type        = map(string)
  default     = {}
}
