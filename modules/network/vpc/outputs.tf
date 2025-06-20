output "vpc_id" {
  description = "The ID of the VPC"
  value       = aws_vpc.this.id
}

output "vpc_name" {
  description = "The name of the VPC"
  value       = aws_vpc.this.tags["Name"]
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = aws_vpc.this.cidr_block
}

output "private_subnets_by_az" {
  description = "Subnets created. Map of AZ name => {subnet_id => id, route_table_id => id, cidr_block => cidr}"
  value       = module.private_subnets.subnets
}

output "gateway_endpoint_ids" {
  description = "Map of gateway endpoint IDs"
  value = { for k, v in aws_vpc_endpoint.gateway_endpoints : k => {
    id  = v.id
    arn = v.arn
  } }
}

output "interface_endpoint_ids" {
  description = "Map of interface endpoint IDs"
  value = { for k, v in aws_vpc_endpoint.interface_endpoints : k => {
    id  = v.id
    arn = v.arn
  } }
}

output "endpoint_security_group_id" {
  description = "ID of the security group containing all VPC endpoints"
  value       = module.endpoint_sg.id
}
