include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//route53"
}

dependency "shared_services_vpc" {
  config_path = "${get_path_to_repo_root()}/network/platform/shared_services_vpc/vpc"
  mock_outputs = {
    vpc_id                 = ["vpc-fake1234567890"]
    vpc_name               = "shared-services-vpc"
    interface_endpoint_ids = {}
  }
}

dependency "app_alb" {
  config_path = "${get_path_to_repo_root()}/network/platform/non_prod_ingress_vpc/app_load_balancer"
  mock_outputs = {
    dns_name = "app-load-balancer-1234567890.us-east-1.elb.amazonaws.com"
    zone_id  = "Z1234567890ABCDEF"
  }
}

inputs = {
  domain                  = "us-east-1.cloud-city.ca.state.sbu"
  short_name              = "cloud-city"
  shared_vpc_ids          = [dependency.shared_services_vpc.outputs.vpc_id]
  interface_endpoints_ids = dependency.shared_services_vpc.outputs.interface_endpoint_ids

  # Tenant/app records here
  tenant_records = {
    # non-prod
    "case-mgmt-api-iva-dev" = {
      name = "case-mgmt-api.iva.dev"
      type = "A"
      alias = {
        name                   = dependency.app_alb.outputs.dns_name
        zone_id                = dependency.app_alb.outputs.zone_id
        evaluate_target_health = true
      }
    }

    # prod
    "case-mgmt-api-iva-prod" = {
      name = "case-mgmt-api.iva"
      type = "A"
      alias = {
        name                   = dependency.app_alb.outputs.dns_name
        zone_id                = dependency.app_alb.outputs.zone_id
        evaluate_target_health = true
      }
    }
  }
}