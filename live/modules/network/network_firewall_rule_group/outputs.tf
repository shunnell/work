output "rule_group_arn" {
  description = "ARN of the Network Firewall Rule Group"
  value       = aws_networkfirewall_rule_group.this.arn
}
