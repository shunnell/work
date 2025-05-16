output "subnets" {
  description = "Subnets created. Map of AZ name => {subnet_id => id, route_table_id => id, cidr_block => cidr}"
  value = { for az in var.availability_zones : az => {
    subnet_id      = aws_subnet.this[az].id,
    route_table_id = aws_route_table.this[az].id,
    cidr_block     = aws_subnet.this[az].cidr_block,
  } }
}