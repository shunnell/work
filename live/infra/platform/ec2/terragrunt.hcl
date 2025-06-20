include "root" {
  path = find_in_parent_folders("root.hcl")
}

include "account" {
  path   = find_in_parent_folders("account.hcl")
  expose = true
}

terraform {
  source = "${get_path_to_repo_root()}/../modules//ec2"
}

inputs = {
  instance_name_prefix = "testing-ec2"
  instance_count       = 1
  enable_guardduty     = true # This is an ATO requirement for non-EKS instances
  # Set to false for EKS instances (should never happen, but here just in case)
  subnet_id              = "subnet-04cd4f7d79093bd7d" # SubnetName: infra-platform-admin-vpc-private-us-east-1b
  vpc_security_group_ids = ["sg-0af3d3d8508d8f640"]   # Default SG with no inbound/outbound rules
  instance_profile_name  = "SSM_access"
  instance_type          = "t3.medium"
  tags = {
    Environment = "IaC"
    Project     = "Cloud-City"
  }
}
