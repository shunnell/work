
# Transit Gateway Routes
resource "aws_ec2_transit_gateway_route" "this" {
  for_each = var.tgw_routes

  destination_cidr_block         = each.value.destination_cidr_block
  transit_gateway_attachment_id  = each.value.transit_gateway_attachment_id
  transit_gateway_route_table_id = each.value.transit_gateway_route_table_id
  blackhole                      = try(each.value.blackhole, false)
}

# VPC Route Tables
resource "aws_route" "this" {
  for_each = var.vpc_route_table_ids

  route_table_id         = each.value.route_table_id
  destination_cidr_block = each.value.destination_cidr_block
  transit_gateway_id     = var.transit_gateway_id
}
