# VPC Resource
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support
  instance_tenancy     = var.instance_tenancy

  tags = merge(
    {
      Name = var.vpc_name
    },
    var.tags
  )
}

# Internet Gateway
resource "aws_internet_gateway" "this" {
  count = var.create_igw ? 1 : 0

  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-igw"
    },
    var.tags
  )
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = var.create_public_subnets ? length(var.public_subnets) : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  map_public_ip_on_launch = var.map_public_ip_on_launch

  tags = merge(
    {
      Name = "${var.vpc_name}-public-${element(var.azs, count.index)}"
      Tier = "Public"
    },
    var.tags
  )
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = var.create_private_subnets ? length(var.private_subnets) : 0
  vpc_id            = aws_vpc.this.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = element(var.azs, count.index)

  tags = merge(
    {
      Name = "${var.vpc_name}-private-${element(var.azs, count.index)}"
      Tier = "Private"
    },
    var.tags
  )
}

# NAT Gateway
resource "aws_eip" "this" {
  count  = var.create_nat_gateway ? var.nat_gateway_count : 0
  domain = "vpc"

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-eip-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_nat_gateway" "this" {
  count         = var.create_nat_gateway ? var.nat_gateway_count : 0
  allocation_id = aws_eip.this[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  tags = merge(
    {
      Name = "${var.vpc_name}-nat-${count.index + 1}"
    },
    var.tags
  )

  depends_on = [aws_internet_gateway.this]
}

# Route Tables
resource "aws_route_table" "public" {
  count  = var.create_public_subnets ? length(var.public_subnets) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-public-rt-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_route" "public_internet_gateway" {
  count                  = var.create_public_subnets && var.create_igw ? length(var.public_subnets) : 0
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.this[0].id
}

resource "aws_route_table" "private" {
  count  = var.create_private_subnets ? length(var.private_subnets) : 0
  vpc_id = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-private-rt-${count.index + 1}"
    },
    var.tags
  )
}

resource "aws_route" "private_nat_gateway" {
  count                  = var.create_private_subnets && var.create_nat_gateway ? var.nat_gateway_count : 0
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# Route Table Associations
resource "aws_route_table_association" "public" {
  count          = var.create_public_subnets ? length(var.public_subnets) : 0
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

resource "aws_route_table_association" "private" {
  count          = var.create_private_subnets ? length(var.private_subnets) : 0
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

# VPC Flow Logs
resource "aws_flow_log" "this" {
  count           = var.enable_flow_logs ? 1 : 0
  iam_role_arn    = var.flow_logs_role_arn
  log_destination = var.flow_logs_destination_arn
  traffic_type    = var.flow_logs_traffic_type
  vpc_id          = aws_vpc.this.id

  tags = merge(
    {
      Name = "${var.vpc_name}-flow-logs"
    },
    var.tags
  )
}
