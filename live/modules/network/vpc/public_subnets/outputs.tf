output "subnets" {
  description = "Subnets created. Map of AZ name => {subnet_id, route_table_id, cidr_block, nat_gateway_id, eip_id}"
  value = { for az in var.availability_zones : az => {
    subnet_id      = module.subnets.subnets[az].subnet_id
    route_table_id = module.subnets.subnets[az].route_table_id
    cidr_block     = module.subnets.subnets[az].cidr_block
    nat_gateway_id = aws_nat_gateway.this[az].id
    eip_id         = aws_eip.this[az].id
  } }
}

output "internet_gateway_id" {
  value = aws_internet_gateway.this.id
}
