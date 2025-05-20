# Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table" "this" {

  transit_gateway_id = var.transit_gateway_id

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# Transit Gateway Route Table Association
resource "aws_ec2_transit_gateway_route_table_association" "this" {
  transit_gateway_attachment_id  = var.transit_gateway_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.this.id
}
