variable "vpc_id" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = string
}

variable "availability_zones" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = set(string)
}

variable "force_cidr_ranges" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = map(string)
  default     = {}
}

variable "width" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = number
}

variable "offset" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = number
}

variable "tags" {
  description = "See equivalently named parameter in 'subnets' module"
  type        = map(string)
  default     = {}
}
