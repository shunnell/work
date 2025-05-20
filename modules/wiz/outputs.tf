output "role_arn" {
  value       = module.wiz_role.role_arn
  description = "Wiz Access Role ARN"
}

output "user_arn" {
  value       = local.is_master_account ? aws_iam_user.wiz_user[0].arn : local.user_arn
  description = "Wiz Access User ARN"
}
