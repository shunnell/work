variable "name_prefix" {
  description = "Prefix used to name all resources"
  type        = string
}

variable "load_balancer_type" {
  description = "The type of Load Balancer"
  type        = string
  default     = "network"
}

variable "target_ports" {
  description = "The ports create Target Groups for"
  type = map(object({
    protocol           = optional(string, "TCP")
    target_type        = optional(string, "ip")
    proxy_protocol_v2  = optional(bool)
    preserve_client_ip = optional(bool)
    health_check = optional(object({
      path     = optional(string)
      protocol = optional(string)
    }))
  }))
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  validation {
    condition     = startswith(var.vpc_id, "vpc-")
    error_message = "VPC ID must start with 'vpc-'"
  }
}

variable "subnet_ids" {
  description = "Subnet IDs"
  type        = list(string)
  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least 1 subnet ID must be passed"
  }
  validation {
    condition     = alltrue([for s in var.subnet_ids : startswith(s, "subnet-")])
    error_message = "All subnet IDs must start with 'subnet-'"
  }
}

variable "target_rules" {
  description = "Target rules for Load Balancer security group; {'rule one' = {target = 'sg-123', type = 'egress'}}"
  type = map(object({
    target = string
    type   = string
  }))
}

variable "tags" {
  description = "Tags to apply to the EKS cluster"
  type        = map(string)
  default     = {}
}
