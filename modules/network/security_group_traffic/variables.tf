variable "security_group_id" {
  description = "Security group ID to which this rule will be attached"
  type        = string
  validation {
    condition     = startswith(var.security_group_id, "sg-")
    error_message = "must be a security group id (e.g. sg-01234)"
  }
}

variable "type" {
  description = "ingress or egress"
  type        = string
  validation {
    condition     = var.type == "ingress" || var.type == "egress"
    error_message = "Must be 'ingress' or 'egress'"
  }
}

variable "description" {
  # Intentionally not nullable to encourage users to specify their purpose, which improves debugging experience:
  description = "Description of this rule's purpose (e.g. 'allow instances to reach database')"
  type        = string
  validation {
    condition     = trimspace(var.description) == var.description && length(var.description) > 0
    error_message = "If set, must have a value and no leading or trailing whitespace"
  }
}

variable "protocol" {
  # Not allowing other protocols or '-1' to prevent the known AWS issue of -1 protocols ignoring port ranges, that's
  # dangerous.
  description = "'tcp' or 'udp'; if null, defaults to 'tcp'"
  type        = string
  nullable    = true // Defaulting is performed in invocation as well
  default     = "tcp"
  validation {
    condition     = var.protocol == null ? true : contains(["tcp", "udp"], var.protocol)
    error_message = "must be 'tcp' or 'udp'"
  }
}

# TODO prefix lists, or ipv6 CIDRs, if we ever need those, should be supported here
variable "target" {
  description = "CIDR block, 'self', or other security group ID to allow 'security_group_id' to egress/ingress to/from"
  type        = string
  validation {
    condition     = var.target == "self" || can(cidrnetmask(var.target)) || startswith(var.target, "sg-")
    error_message = "Must be a CIDR mask, 'self', or a security group id (e.g. sg-01234)"
  }
}

variable "create_explicit_egress_to_target_security_group" {
  description = "Whether to create an explicit egress rule from the source SG to the target SG. Ignored unless 'type' is 'egress' and 'target' is a security group"
  type        = bool
  nullable    = true
  default     = false
}

variable "ports" {
  description = "List of ports that this rule will apply to; [0] for all ports"
  type        = list(number)
  validation {
    condition     = length(var.ports) > 0
    error_message = "At least one port must be specified"
  }
  validation {
    condition     = length(var.ports) == 1 ? true : var.ports == range(var.ports[0], var.ports[length(var.ports) - 1])
    error_message = "Ports must be specified in a contiguous range; create multiple rules for non-contiguous ranges"
  }
  validation {
    condition     = alltrue([for p in var.ports : p >= 0])
    error_message = "Ports must be positive"
  }
}
