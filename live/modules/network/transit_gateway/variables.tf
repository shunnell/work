variable "name" {
  description = "Name to be used on all the resources as identifier"
  type        = string
}

variable "description" {
  description = "Description of the Transit Gateway"
  type        = string
  default     = null
}


variable "amazon_side_asn" {
  description = "Private Autonomous System Number (ASN) for the Amazon side of a BGP session"
  type        = number
  default     = 64512
}

variable "auto_accept_shared_attachments" {
  description = "Whether resource attachment requests are automatically accepted"
  type        = string
  default     = "disable"
}

variable "default_route_table_association" {
  description = "Whether resource attachments are automatically associated with the default route table"
  type        = string
  default     = "disable"
}

variable "default_route_table_propagation" {
  description = "Whether resource attachments automatically propagate routes to the default route table"
  type        = string
  default     = "disable"
}

variable "enable_dns_support" {
  description = "Should DNS support be enabled?"
  type        = bool
  default     = true
}

variable "enable_vpn_ecmp_support" {
  description = "Should VPN Equal Cost Multipath Protocol support be enabled?"
  type        = bool
  default     = true
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

variable "ram_allow_external_principals" {
  description = "Should principals outside your organization be associated with your resource share"
  type        = bool
  default     = false
}
