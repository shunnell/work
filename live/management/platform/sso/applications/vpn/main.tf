variable "instance_arn" {
  type        = string
  description = "SSO Instance ARN"
}

resource "aws_ssoadmin_application" "vpn" {
  name                     = "AWS Client VPN"
  description              = "AWS Client VPN application SSO"
  application_provider_arn = "arn:aws:sso::aws:applicationProvider/custom-saml"
  instance_arn             = var.instance_arn
  portal_options {
    visibility = "ENABLED"
    sign_in_options {
      origin = "IDENTITY_CENTER"
    }
  }
}

output "application_arn" {
  description = "ARN of the Application"
  value       = aws_ssoadmin_application.vpn.application_arn
}
