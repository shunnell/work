# This file provizions the permissions needed for the Wiz security scanner's access to Cloud City, which is implemented
module "wiz" {
  source                    = "../../wiz"
  data-scanning             = true
  lightsail-scanning        = false
  eks-scanning              = true
  terraform-bucket-scanning = true
  cloud-cost-scanning       = true
  # Externally-supplied Wiz tenant ID. Not a secret.
  external_id = "45255fed-d54a-4731-8322-be7378da849c"
  # This role ARN obtained via Wiz UI: Account Profile circle -> "Tenant Info" -> "AWS Commercial Trust Policy Role":
  wiz_external_role_arns = ["arn:aws:iam::260212806598:role/fedramp-us1-AssumeRoleCommercialDelegator"]
  tags                   = var.tags
  # Some requested quotas must be raised for the Wiz IAM internals to attach all required policies:
  depends_on = [aws_servicequotas_service_quota.quotas]
}

output "wiz_role_arn" {
  description = "ARN of the role used by Wiz for security scanning (present in all Cloud City accounts)"
  value       = module.wiz.role_arn
}
