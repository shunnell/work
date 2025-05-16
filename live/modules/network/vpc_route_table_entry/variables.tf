variable "routes" {
  description = "List of routes to be added to the route table"
  type = list(object({
    route_table_id             = string
    destination_cidr_block     = string
    destination_prefix_list_id = optional(string)
    gateway_id                 = optional(string)
    nat_gateway_id             = optional(string)
    network_interface_id       = optional(string)
    transit_gateway_id         = optional(string)
    vpc_peering_connection_id  = optional(string)
    vpc_endpoint_id            = optional(string)
  }))
  default = []
}
