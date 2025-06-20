# This module sets the IAM password complexity/rotation requirements for a given tenant account.
# Accounts should never *ever* have static IAM users (key/secret/password creds), but even when static users don't exist
# Security Hub still complains about compliance controls like IAM.7 which requires a policy to require complex
# passwords. This prevents those findings, as it's simpler to automate remediation of them than it is to explain that
# static IAM users are not threat vectors in our system.
# Example control: https://docs.aws.amazon.com/securityhub/latest/userguide/iam-controls.html#iam-7
resource "aws_iam_account_password_policy" "security_hub_compliance" {
  minimum_password_length        = 16
  require_lowercase_characters   = true
  require_numbers                = true
  require_uppercase_characters   = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
}
