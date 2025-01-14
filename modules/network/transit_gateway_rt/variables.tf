variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
  default     = ""
}

variable "tgw_routes" {
  description = "Maps of maps of Transit Gateway routes"
  type        = map(any)
  default     = {}
}

variable "vpc_route_table_ids" {
  description = "Map of VPC route table IDs and their routes to the Transit Gateway"
  type        = map(any)
  default     = {}
}