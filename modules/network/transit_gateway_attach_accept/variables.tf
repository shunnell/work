variable "transit_gateway_attachment_id" {
  description = "Transit Gateway attachment ID only used if transit_gateway_attachment_accept is true"
  type        = string
  default     = ""
}

variable "transit_gateway_default_route_table_association" {
  description = "Whether to associate the Transit Gateway attachment with the default route table"
  type        = bool
  default     = false
}

variable "transit_gateway_default_route_table_propagation" {
  description = "Whether to propagate routes to the default route table"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to the Transit Gateway attachment"
  type        = map(string)
  default     = {}
}

