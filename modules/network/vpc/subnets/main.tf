resource "aws_subnet" "this" {
  for_each          = var.availability_zones
  vpc_id            = var.vpc_id
  cidr_block        = local.az_to_cidr[each.key]
  availability_zone = each.key

  tags = merge(
    local.tags,
    {
      Name                              = "${local.vpc_name}-${var.name}-${each.key}"
      "kubernetes.io/role/internal-elb" = lower(var.tier) == "private" ? "1" : "0"
    }
  )
}

resource "aws_route_table" "this" {
  for_each = var.availability_zones
  vpc_id   = var.vpc_id

  tags = merge(
    local.tags,
    { Name = "${local.vpc_name}-${var.name}-rt-${each.key}" },
  )
}

resource "aws_route_table_association" "this" {
  for_each       = var.availability_zones
  subnet_id      = aws_subnet.this[each.key].id
  route_table_id = aws_route_table.this[each.key].id
}
