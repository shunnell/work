variable "name" {
  description = "Security group name (one of name and name_prefix must be specified)"
  type        = string
  nullable    = true
  default     = null
  validation {
    condition     = toset([var.name == null, var.name_prefix == null]) == toset([true, false])
    error_message = "One and only one of 'name' and 'name_prefix' must be set"
  }
}


variable "name_prefix" {
  description = "Security group name (one of name and name_prefix must be specified)"
  type        = string
  nullable    = true
  default     = null
}

variable "description" {
  description = "Description of the security group's purpose"
  type        = string
  nullable    = true
  default     = null
  validation {
    condition     = var.description == null ? true : length(var.description) > 10
    error_message = "A useful description (length > 10) is required"
  }
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "VPC ID must start with 'vpc-'"
  }
}


variable "tags" {
  description = "Tags"
  type        = map(string)
  default     = {}
}

variable "allow_all_outbound_traffic" {
  description = "Whether this security group should allow all outbound traffic"
  type        = bool
  default     = false
}

variable "revoke_rules_on_delete" {
  description = "See Terraform documentation for the parameter of the same name on aws_security_group"
  type        = bool
  default     = false
}

variable "rules" {
  description = "Rules to add to this security group; a list of maps/objects to be supplied as arguments to the 'security_group_traffic' resource."
  type = map(object({
    protocol = optional(string)
    type     = string
    ports    = list(number)
    target   = string
    // create_explicit_egress_to_target_security_group intentionally omitted; it is defaulted based on 'allow_all_outbound_traffic'.
  }))
  default = {}
}
