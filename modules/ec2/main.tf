# The idea here is to create an EC2 instance and forget about it"
# In other words, we do not want to manage the lifecycle of the EC2 instance" {

data "aws_instances" "existing" {
  filter {
    name   = "tag:TG-IAC"
    values = ["do-not-delete"]
  }
  filter {
    name   = "instance-state-name"
    values = ["pending", "running", "stopped", "stopping"]
  }
}

data "aws_region" "current" {}

data "aws_ami" "amazon_linux2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

resource "aws_guardduty_detector" "this" {
  count  = var.enable_guardduty ? 1 : 0
  enable = true
  lifecycle {
    prevent_destroy = true
  }
}

locals {
  existing_count = length(data.aws_instances.existing.ids)
  total_count    = local.existing_count + var.instance_count

  # Build a 1..total_count list of unique names:
  #   ["prefix-1", "prefix-2", etc., "prefix-N"]
  instance_name_list = [
    for idx in range(local.total_count) :
    "${var.instance_name_prefix}-${idx + 1}"
  ]
  instance_name_set = toset(local.instance_name_list)
}

resource "aws_instance" "this" {
  for_each               = local.instance_name_set
  ami                    = data.aws_ami.amazon_linux2.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.instance_profile_name != "" ? var.instance_profile_name : null

  user_data = <<-EOF
    #!/bin/bash
    systemctl enable amazon-ssm-agent
    systemctl start amazon-ssm-agent
    %{if var.enable_guardduty}
    yum install -y aws-guardduty-security-agent
    systemctl enable aws-guardduty-security-agent
    systemctl start aws-guardduty-security-agent
    %{endif}
  EOF

  tags = merge(
    var.tags,
    var.enable_guardduty ? { GuardDuty = var.name_tag } : {},
    {
      Name   = each.key
      TG-IAC = "do-not-delete" # So future runs count this instance
    }
  )
  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      ami,
      instance_type,
      subnet_id,
      vpc_security_group_ids,
      iam_instance_profile,
      user_data,
      tags
    ]
  }
}
