data "aws_organizations_organization" "current" {}

output "accounts" {
  description = "All the active accounts"
  value       = { for account in data.aws_organizations_organization.current.accounts : account.id => account.name if account.status == "ACTIVE" }
}
