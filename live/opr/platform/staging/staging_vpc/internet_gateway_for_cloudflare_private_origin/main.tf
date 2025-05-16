# See adjacent README.md for details on why this exists.
variable "vpc_id" {
  type = string
}

variable "vpc_name" {
  type = string
}

resource "aws_internet_gateway" "igw_for_opr_private_origin" {
  vpc_id = var.vpc_id
  tags   = { Name = "non-routed-igw-for-${var.vpc_name}-cf-private-origin" }
}

output "igw_id" {
  value = aws_internet_gateway.igw_for_opr_private_origin.id
}
