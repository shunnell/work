include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//network/app_load_balancer"
}

inputs = {
  name_prefix        = "non-prod-multitenant"
  vpc_id             = "vpc-0d2956665b19249f7"
  subnets            = ["subnet-0ce9cbb0e870c0aa8", "subnet-0a806fc68f88c229d"]
  security_group_ids = ["sg-0a1d550d4973c42f9"]
  certificate_arn    = "arn:aws:acm:us-east-1:123456789012:certificate/abcd-efgh" #TODO: Replace with actual certificate ARN
  region             = "us-east-1"

  tenants = {
    app1 = { host_header = "app1.us-east-1.cloud-city.ca.state.sbu", priority = 10, port = 80 }
    app2 = { host_header = "app2.us-east-1.cloud-city.ca.state.sbu", priority = 20, port = 80 }
    app3 = { host_header = "app3.us-east-1.cloud-city.ca.state.sbu", priority = 30, port = 80 }
  }

  tags = {
    Environment = "non-prod"
    Project     = "MultiTenantApp"
  }
}
