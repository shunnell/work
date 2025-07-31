resource "aws_ram_resource_share" "this" {
  name                      = var.name
  allow_external_principals = var.allow_external_principals

  tags = var.tags
}

resource "aws_ram_resource_association" "this" {
  count = length(var.resource_arns)

  resource_arn       = var.resource_arns[count.index]
  resource_share_arn = aws_ram_resource_share.this.arn
}

resource "aws_ram_principal_association" "this" {
  count = length(var.principal_arns)

  principal          = var.principal_arns[count.index]
  resource_share_arn = aws_ram_resource_share.this.arn
}