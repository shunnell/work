output "firewall_id" {
  description = "ID of the Network Firewall"
  value       = aws_networkfirewall_firewall.this.id
}

output "firewall_arn" {
  description = "ARN of the Network Firewall"
  value       = aws_networkfirewall_firewall.this.arn
}

output "endpoint_ids" {
  description = "List of VPC endpoint IDs for the Network Firewall"
  value = {
    for sync_state in aws_networkfirewall_firewall.this.firewall_status[0].sync_states :
    sync_state.availability_zone => {
      endpoint_id = sync_state.attachment[0].endpoint_id
      subnet_id   = sync_state.attachment[0].subnet_id
    }
  }
}


