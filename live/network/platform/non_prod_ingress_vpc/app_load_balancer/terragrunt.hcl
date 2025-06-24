include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/app_load_balancer"
}

dependency "vpc" {
  config_path = "${get_path_to_repo_root()}/network/platform/non_prod_ingress_vpc/vpc"
  mock_outputs = {
    vpc_id         = "vpc-abcdef1234567890"
    public_subnets = ["subnet-11111111", "subnet-22222222", "subnet-33333333"]
  }
}

inputs = {
  name_prefix = "non-prod-multitenant"
  vpc_id      = dependency.vpc.outputs.vpc_id
  # use public subnets for the ALB
  subnets         = dependency.vpc.outputs.public_subnets
  certificate_arn = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh" # TODO: Create story, need to swap in real ARN
  # region          = "us-east-1"
  allowed_ingress_cidrs = [
    "204.51.100.33/32" # Replace with as narrow of a CIDR block as possible
  ]  


  tenants = {
    app1 = {
      host_header = "app1.us-east-1.cloud-city.ca.state.sbu"
      priority    = 10
      port        = 80
    }
    app2 = {
      host_header = "app2.us-east-1.cloud-city.ca.state.sbu"
      priority    = 20
      port        = 80
    }
    app3 = {
      host_header = "app3.us-east-1.cloud-city.ca.state.sbu"
      priority    = 30
      port        = 80
    }
  }

  tags = {
    Environment = "non-prod"
    Project     = "MultiTenantApp"
  }

}
