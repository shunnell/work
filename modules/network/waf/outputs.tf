output "web_acl_id" {
  description = "WAF Classic (regional) Web ACL ID."
  value       = aws_wafregional_web_acl.this.id
}

output "web_acl_arn" {
  description = "WAF Classic (regional) Web ACL ARN."
  value       = aws_wafregional_web_acl.this.arn
}
