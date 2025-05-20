data "aws_region" "current" {}

locals {
  tags = merge(var.tags, {
    vpc_name = var.vpc_name
  })
}