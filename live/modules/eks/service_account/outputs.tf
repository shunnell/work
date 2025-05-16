output "iam_role_arn" {
  value      = module.irsa_role.iam_role_arn
  depends_on = [module.irsa_role, kubernetes_service_account.this]
}

output "service_account_name" {
  # Provides null if no account was created, even though we could return var.name. 'null' discourages folks from
  # depending on this module's resources when they shouldn't (if the SA is created elsewhere, that should be the
  # dependency, not this module).
  value      = var.create_service_account ? kubernetes_service_account.this[0].metadata[0].name : null
  depends_on = [module.irsa_role, kubernetes_service_account.this]
}
