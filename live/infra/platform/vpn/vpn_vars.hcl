locals {
  # Transit Gateway
  transit_gateway_id = "tgw-0e789e42aaa2beb19"

  # Transit Gateway Attachment
  vpn_transit_gateway_attachment_id = "tgw-attach-02fb4b2693de974c7"
  dso_transit_gateway_attachment_id = "tgw-attach-07ed5cbe1d23892dd"

  # Transit Gateway Route Table
  vpn_transit_gateway_route_table_id = "tgw-rtb-05ef4de680a3ff044"
  dso_transit_gateway_route_table_id = "tgw-rtb-0c3eaa48975afd797"

  # common CIDR blocks (VPN and DSO)
  dso_cidr_block = "172.16.0.0/16"
  vpn_cidr_block = "172.40.0.0/16"
}