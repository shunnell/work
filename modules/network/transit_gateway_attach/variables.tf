variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the Transit Gateway Attachment"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
  default     = ""
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
  default     = []
}

variable "dns_support" {
  description = "DNS support"
  type        = string
  default     = "enable"
}

variable "ipv6_support" {
  description = "IPv6 support"
  type        = string
  default     = "disable"
}

variable "appliance_mode_support" {
  description = "Appliance mode support"
  type        = string
  default     = "disable"
}

variable "transit_gateway_default_route_table_association" {
  description = "Transit Gateway default route table association"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Transit Gateway default route table propagation"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

