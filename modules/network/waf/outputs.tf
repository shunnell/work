output "web_acl_id" {
  description = "WAF Classic (regional) Web ACL ID."
  value       = aws_wafregional_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAF Classic (regional) Web ACL ARN."
  value       = aws_wafregional_web_acl.this.arn
}

output "association_id" {
  description = "ID of the Web ACL association with your resource."
  value       = aws_wafregional_web_acl_association.this.id
}

output "managed_rule_id" {
  description = "The ID of the managed rule group in use."
  value       = local.effective_managed_rule_id
}
