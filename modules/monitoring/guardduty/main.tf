data "aws_region" "current" {}

data "aws_instances" "all" {}

data "aws_instances" "eks" {
  filter {
    name   = "tag-key"
    values = [var.eks_tag_key]
  }
}

locals {
  target_instance_ids = tolist(
    setsubtract(data.aws_instances.all.ids, data.aws_instances.eks.ids)
  )
}

resource "aws_ssm_document" "ensure_guardduty_agent" {
  name          = "EnsureGuardDutyRuntimeAgent"
  document_type = "Command"

  content = jsonencode({
    schemaVersion = "2.2",
    description   = "Ensures GuardDuty runtime monitoring agent is installed and running",
    mainSteps = [
      {
        name   = "ensureGuarddutyAgent",
        action = "aws:runShellScript",
        inputs = {
          runCommand = [
            "#!/bin/bash",
            "if ! systemctl is-active --quiet guardduty-agent; then",
            "  yum install -y amazon-guardduty-agent || apt-get install -y amazon-guardduty-agent",
            "  systemctl enable guardduty-agent",
            "  systemctl start guardduty-agent",
            "fi"
          ]
        }
      }
    ]
  })
}

resource "aws_ssm_association" "guardduty_state_manager" {
  name = aws_ssm_document.ensure_guardduty_agent.name
  targets {
    key    = "InstanceIds"
    values = local.target_instance_ids
  }

  schedule_expression = "rate(1 hour)"
  compliance_severity = "HIGH"
  association_name    = "GuardDuty-StateManager"
  depends_on          = [aws_ssm_document.ensure_guardduty_agent]
}

output "ec2_target_count" {
  description = "Count of EC2 instances managed by State Manager"
  value       = length(local.target_instance_ids)
}
