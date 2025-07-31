locals {
  # Load common variables
  admin_vars   = read_terragrunt_config(find_in_parent_folders("dev.hcl")).locals
  network_vars = read_terragrunt_config("${get_path_to_repo_root()}/network/account.hcl").locals

  # Extract commonly used variables
  common_identifier             = local.admin_vars.common_identifier
  network_terragrunter_role_arn = local.network_vars.terragrunter_role_arn
  region                        = local.network_vars.region

  # VPC CIDR block
  vpc_cidr_block = "172.20.64.0/20"
}
