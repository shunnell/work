variable "vpc_id" {
  description = "ID of the VPC where subnets will be created"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

variable "subnets_config" {
  description = "Configuration for subnets including availability zones and CIDR blocks"
  type = list(object({
    az            = string
    custom_subnet = string
  }))
  nullable = false
}

variable "subnet_name" {
  description = "Name of the subnet"
  type        = string
}

variable "type" {
  description = "Type of the subnet"
  type        = string
  default     = "private"
}

variable "public_subnets" {
  description = "List of public subnets"
  type        = list(string)
  default     = []

}

variable "create_nat_gateway" {
  description = "Controls if NAT Gateway(s) should be created"
  type        = bool
  default     = false
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create"
  type        = number
  default     = 1
}

variable "tags" {
  description = "Common tags for all resources"
  type        = map(string)
  default     = {}
}
