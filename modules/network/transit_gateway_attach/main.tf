# VPC Attachment
resource "aws_ec2_transit_gateway_vpc_attachment" "this" {

  transit_gateway_id = var.transit_gateway_id
  vpc_id             = var.vpc_id
  subnet_ids         = var.subnet_ids

  dns_support                                     = var.dns_support
  ipv6_support                                    = var.ipv6_support
  appliance_mode_support                          = var.appliance_mode_support
  transit_gateway_default_route_table_association = var.transit_gateway_default_route_table_association
  transit_gateway_default_route_table_propagation = var.transit_gateway_default_route_table_propagation

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}
# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "this" {

  transit_gateway_id = var.transit_gateway_id


  tags = merge(
    {
      Name = "${var.name}-rt"
    },
    var.tags
  )
}

# Transit Gateway Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.this.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
