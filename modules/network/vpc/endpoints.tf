resource "aws_vpc_endpoint" "interface_endpoints" {
  for_each            = var.interface_endpoints
  vpc_id              = aws_vpc.this.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = values(module.private_subnets.subnets)[*].subnet_id
  security_group_ids  = [module.endpoint_sg.id]
  auto_accept         = true
  private_dns_enabled = var.enable_dns
  tags = merge(local.tags, {
    Name = "${var.vpc_name}-${each.key}-if"
  })
  depends_on = [aws_vpc_endpoint.gateway_endpoints]
}

resource "aws_vpc_endpoint" "gateway_endpoints" {
  for_each          = var.gateway_endpoints
  vpc_endpoint_type = "Gateway"
  vpc_id            = aws_vpc.this.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.${each.key}"
  route_table_ids   = values(module.private_subnets.subnets)[*].route_table_id
  tags = merge(local.tags, {
    Name = "${var.vpc_name}-${each.key}-gw"
  })
}

module "endpoint_sg" {
  source                     = "../security_group"
  description                = "Security Group for Interface VPC Endpoints"
  allow_all_outbound_traffic = false # Endpoints won't ever contact anything independently
  vpc_id                     = aws_vpc.this.id
  name                       = "${var.vpc_name}-endpoints" # Name instead of name_prefix forces there to only be one VPC with a name per account
  tags                       = local.tags
  rules = {
    "Access endpoints from entire VPC" = {
      ports    = [443]
      type     = "ingress"
      protocol = "tcp"
      target   = var.vpc_cidr
    }
  }
}