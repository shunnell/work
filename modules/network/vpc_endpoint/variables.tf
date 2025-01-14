variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where endpoints will be created"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  type        = string
}

variable "private_subnet_ids" {
  description = "The IDs of the private subnets to associate with the VPC endpoint"
  type        = list(string)
}

variable "tags" {
  description = "Additional tags for resources"
  type        = map(string)
  default     = {}
}

variable "gateway_endpoints" {
  description = "Map of gateway endpoints to create"
  type = map(object({
    route_table_ids = list(string)
  }))
  default = {}
}

variable "interface_endpoints" {
  description = "Map of interface endpoints to create"
  type = map(object({
    service_name        = string
    private_dns_enabled = bool
  }))
  default = {}
}
