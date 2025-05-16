# This module is a lookup of AWS managed permission sets by name
# Allowing other code to have reliable references without copy-pasting full arns
data "aws_ssoadmin_instances" "instances" {}

data "aws_ssoadmin_permission_set" "AWSPowerUserAccess" {
  instance_arn = tolist(data.aws_ssoadmin_instances.instances.arns)[0]
  name         = "AWSPowerUserAccess"
}

output "AWSPowerUserAccess" {
  value = {
    name = data.aws_ssoadmin_permission_set.AWSPowerUserAccess.name
    arn  = data.aws_ssoadmin_permission_set.AWSPowerUserAccess.arn
  }
}

data "aws_ssoadmin_permission_set" "AWSAdministratorAccess" {
  instance_arn = tolist(data.aws_ssoadmin_instances.instances.arns)[0]
  name         = "AWSAdministratorAccess"
}

output "AWSAdministratorAccess" {
  value = {
    name = data.aws_ssoadmin_permission_set.AWSPowerUserAccess.name
    arn  = data.aws_ssoadmin_permission_set.AWSPowerUserAccess.arn
  }
}