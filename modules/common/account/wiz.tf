module "wiz" {
  source                    = "../../wiz"
  data-scanning             = true  # Copied verbatim from Wiz terraform defaults.
  lightsail-scanning        = false # Copied verbatim from Wiz terraform defaults.
  eks-scanning              = true  # Copied verbatim from Wiz terraform defaults.
  terraform-bucket-scanning = true  # Copied verbatim from Wiz terraform defaults.
  # Externally-supplied Wiz tenant ID. Not a secret.
  external_id = "45255fed-d54a-4731-8322-be7378da849c"
  # NB: this is probably wrong; it was presented as a possible way to remediate Wiz backend issues (see wiz/README.md)
  # temporarily. It didn't work and should potentially be changed in future.
  assume_role_principals = []             # Eventually might be e.g. "arn:aws:iam::260212806598:role/fedramp-us1-AssumeRoleCommercialDelegator"
  master_account_id      = "590183957203" # Cloud City management account
}

output "wiz_role_arn" {
  value = module.wiz.role_arn
}

output "wiz_user_arn" {
  value = module.wiz.user_arn
}