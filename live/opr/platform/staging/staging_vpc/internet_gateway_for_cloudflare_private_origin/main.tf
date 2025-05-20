# See adjacent README.md for details on why this exists.
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
}

resource "aws_internet_gateway" "igw_for_opr_private_origin" {
  vpc_id = var.vpc_id
  tags = {
    Name       = "non-routed-igw-for-${var.vpc_name}-cf-private-origin"
    for_tenant = "opr"
  }
}

output "igw_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.igw_for_opr_private_origin.id
}
