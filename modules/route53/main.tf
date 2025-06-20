resource "aws_route53_zone" "this" {
  name    = var.domain
  comment = "Cloud-City provisioned hosted zone: ${var.domain}"
  tags    = var.tags

  vpc {
    vpc_id = var.vpc_id
  }
}

resource "aws_route53profiles_profile" "this" {
  name = "${var.short_name}-profile"
  tags = var.tags
}

resource "aws_route53profiles_resource_association" "this" {
  name         = "${var.short_name}-profile-zone-association"
  profile_id   = aws_route53profiles_profile.this.id
  resource_arn = aws_route53_zone.this.arn
}

resource "aws_route53profiles_association" "this" {
  name        = "${var.vpc_name}-association"
  profile_id  = aws_route53profiles_profile.this.id
  resource_id = var.vpc_id
}

# Profile Association for shared services interface endpoints
# TODO: This resource has a know bug https://github.com/hashicorp/terraform-provider-aws/pull/42562 
# and the terraform apply fails but the VPC endpoints are associated properly.

resource "aws_route53profiles_resource_association" "endpoints" {
  for_each     = var.interface_endpoints_ids
  name         = replace("${each.key}-endpoint-association", ".", "-")
  profile_id   = aws_route53profiles_profile.this.id
  resource_arn = each.value.arn
}

# RAM Resource Share for Route53 Profile
resource "aws_ram_resource_share" "this" {
  name                      = "${var.short_name}-profile-share"
  allow_external_principals = false
  tags                      = var.tags
}

# RAM Association for Route53 Profile
resource "aws_ram_resource_association" "this" {
  resource_arn       = aws_route53profiles_profile.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}

data "aws_organizations_organization" "this" {}

# RAM Association for Route53 Profile
resource "aws_ram_principal_association" "this" {
  principal          = data.aws_organizations_organization.this.arn
  resource_share_arn = aws_ram_resource_share.this.arn
}
