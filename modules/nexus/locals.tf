locals {
  env_suffix = var.env_suffix != "" ? "-${var.env_suffix}" : ""

  irsa_name          = "nexus-irsa${local.env_suffix}"
  namespace          = "nexusrepo${local.env_suffix}"
  secretstore_name   = "nexus-irsa-store${local.env_suffix}"
  rds_ext_secret     = "nexus-rds-${var.rds_secret}"
  license_ext_secret = var.license_secret_name
}