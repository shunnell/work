# Ensure the block public sharing setting is enabled for AWS Systems Manager documents - remediating critical findings
# stemming from AWS Best Practices security scans.
# This setting prevents SSM documents from being publicly shared, enhancing security by restricting access.

data "aws_region" "current" {}

resource "aws_ssm_service_setting" "block_public_share" {
  setting_id    = "arn:aws:ssm:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:servicesetting/ssm/documents/console/public-sharing-permission"
  setting_value = "Disable"
}