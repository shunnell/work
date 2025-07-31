variable "name" {
  description = "Name of the RAM resource share"
  type        = string
}

variable "allow_external_principals" {
  description = "Whether to allow sharing with external principals"
  type        = bool
  default     = false
}

variable "resource_arns" {
  description = "List of resource ARNs to share"
  type        = list(string)
}

variable "principal_arns" {
  description = "List of principal ARNs (AWS account IDs, organization IDs, or organizational unit IDs) to share resources with"
  type        = list(string)
}

variable "tags" {
  description = "Tags to add to the RAM resource share"
  type        = map(string)
  default     = {}
}