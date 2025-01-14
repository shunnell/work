# Transit Gateway
resource "aws_ec2_transit_gateway" "this" {

  description                     = var.description
  amazon_side_asn                 = var.amazon_side_asn
  auto_accept_shared_attachments  = var.auto_accept_shared_attachments
  default_route_table_association = var.default_route_table_association
  default_route_table_propagation = var.default_route_table_propagation
  dns_support                     = var.enable_dns_support ? "enable" : "disable"
  vpn_ecmp_support                = var.enable_vpn_ecmp_support ? "enable" : "disable"

  tags = merge(
    {
      Name = var.name
    },
    var.tags
  )
}

# RAM Share for Transit Gateway
resource "aws_ram_resource_share" "this" {

  name                      = "${var.name}-share"
  allow_external_principals = var.ram_allow_external_principals

  tags = merge(
    {
      Name = "${var.name}-share"
    },
    var.tags
  )
}

# RAM Association for Transit Gateway
resource "aws_ram_resource_association" "this" {

  resource_arn       = aws_ec2_transit_gateway.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}

