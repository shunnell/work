# Create private subnet
resource "aws_subnet" "this" {
  count             = length(var.subnets_config)
  vpc_id            = var.vpc_id
  cidr_block        = var.subnets_config[count.index].custom_subnet
  availability_zone = var.subnets_config[count.index].az

  tags = merge(
    {
      Name = "${var.vpc_name}-${var.subnet_name}-${var.subnets_config[count.index].az}"
      Tier = var.type
    },
    var.tags
  )
}

# Create NAT Gateway (if requested)
resource "aws_eip" "this" {
  count  = var.create_nat_gateway && length(var.public_subnets) > 0 ? var.nat_gateway_count : 0
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.vpc_name}-${var.subnet_name}-nat-eip-${count.index + 1}" })
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat_gateway && length(var.public_subnets) > 0 ? var.nat_gateway_count : 0
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = var.public_subnets[count.index]

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-${count.index + 1}"
    },
    var.tags
  )
}

# Create route table
resource "aws_route_table" "this" {
  count  = length(var.subnets_config)
  vpc_id = var.vpc_id

  tags = merge(
    var.tags,
    {
      Name = "${var.vpc_name}-${var.subnet_name}-rt-${count.index + 1}"
      Type = var.type
    }
  )
}

# Associate route table with subnet
resource "aws_route_table_association" "this" {
  count          = length(var.subnets_config)
  subnet_id      = aws_subnet.this[count.index].id
  route_table_id = aws_route_table.this[count.index].id
}

# Add NAT Gateway route if NAT is created
resource "aws_route" "this" {
  count                  = var.create_nat_gateway && length(var.public_subnets) > 0 ? var.nat_gateway_count : 0
  route_table_id         = aws_route_table.this[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}
