include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules/monitoring/cloudwatch_log_group"
}

locals {
  # Load common variables
  inspection_vpc_vars = read_terragrunt_config(find_in_parent_folders("non_prod_inspection_vpc.hcl"))

  # Extract commonly used variables
  common_identifier = local.inspection_vpc_vars.locals.common_identifier
  vpc_name          = local.inspection_vpc_vars.locals.vpc_name
  default_tags      = local.inspection_vpc_vars.locals.default_tags
}

inputs = {
  log_group_name = "/aws/vpc/flow-logs/${local.common_identifier}"
  retention_days = 30

  tags = merge(local.default_tags, {
    vpc_name = local.vpc_name
  })
}
