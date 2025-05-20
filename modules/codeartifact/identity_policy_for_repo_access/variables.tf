# Dummy provider requirement block to pull the arn_parse function's namespace into scope:
# https://github.com/hashicorp/terraform/issues/35753
terraform {
  required_providers {
    aws = {}
  }
}

variable "repositories" {
  description = "ARNs for CodeArtifact repositories to which this policy should have access"
  type = object({
    pull = set(string)
    push = set(string)
  })
  default = {
    pull = []
    push = []
  }

  validation {
    condition = alltrue([
      for k, v in var.repositories : alltrue([
        for arn in v : can(provider::aws::arn_parse(arn))
      ])
    ])
    error_message = "Each ARN must be a valid AWS ARN for CodeArtifact respository."
  }
}
