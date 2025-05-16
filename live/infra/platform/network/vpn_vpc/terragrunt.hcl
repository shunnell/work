include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "vpn_vars" {
  path   = "../../vpn/vpn_vars.hcl"
  expose = true
}

terraform {
  source = "${get_repo_root()}/../modules//network/vpc"
}

dependency "cloudwatch_sharing_target" {
  config_path = "${get_path_to_repo_root()}/logs/platform/monitoring/cloudwatch_to_splunk_shipment_destinations/vpc_flow_logs"
  mock_outputs = {
    cloudwatch_destination_arn = "arn:aws:iam::111111111111:sink/12345678-4bf3-4d48-9632-908ca744edd7"
  }
}

inputs = {
  vpc_name                     = "cloudcity-VPN-vpc"
  vpc_cidr                     = include.vpn_vars.locals.vpn_cidr_block
  log_shipping_destination_arn = dependency.cloudwatch_sharing_target.outputs.cloudwatch_destination_arn
  availability_zones = [
    "us-east-1a",
    "us-east-1b",
  ]
  # TODO we should significantly rethink the CIDR allocation strategy of the VPN VPC. The below are only selected
  #   because they were  pre-existing on the old clickops VPC.
  force_subnet_cidr_ranges = {
    "us-east-1a" = "172.40.128.0/20",
    "us-east-1b" = "172.40.144.0/20",
  }
  # NB: I don't *think* we need VPC endpoints usable on the VPN VPC, since VPN users should be split-tunnelling and
  # thus able to use public AWS endpoints instead. If we stop split-tunnelling or discover other endpoint needs, we can
  # add them here if we consider those usages appropriate.
  interface_endpoints = []
  gateway_endpoints   = []
}
