variable "create_domain" {
  description = "Whether to create a new CodeArtifact domain"
  type        = bool
  default     = false
}

variable "domain_name" {
  description = "The name of the CodeArtifact domain"
  type        = string
}

variable "kms_key_arn" {
  description = "The ARN of a KMS key used for encrypting the domain's assets"
  type        = string
  default     = null
}

variable "repositories" {
  description = "List of repositories to create in the domain"
  type = list(object({
    name                  = string
    description           = string
    upstream_repositories = optional(list(string))
    external_connections  = optional(list(string))
  }))
  default = []
}

variable "tags" {
  description = "A map of tags to assign to all resources"
  type        = map(string)
  default     = {}
}
