# Gateway VPC Endpoints (S3 and DynamoDB)
resource "aws_vpc_endpoint" "this_gateway" {
  for_each = var.gateway_endpoints

  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.${each.key}"

  route_table_ids = each.value.route_table_ids

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-${each.key}-endpoint"
  })
}

# Security Group for VPC Endpoints
resource "aws_security_group" "this" {
  name        = "${var.vpc_name}-vpc-endpoint-sg"
  description = "Security group for VPC Endpoints"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr_block]
  }

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-vpc-endpoint-sg"
  })
}

# Interface VPC Endpoints
resource "aws_vpc_endpoint" "this_interface" {
  for_each = var.interface_endpoints

  vpc_id             = var.vpc_id
  service_name       = each.value.service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.private_subnet_ids
  security_group_ids = [aws_security_group.this.id]

  private_dns_enabled = each.value.private_dns_enabled

  tags = merge(var.tags, {
    Name = "${var.vpc_name}-${each.key}-endpoint"
  })
}
