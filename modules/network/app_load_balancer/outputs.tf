output "alb_arn" {
  description = "ARN of the Application Load Balancer."
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name of the ALB (to use in Route 53, etc.)."
  value       = aws_lb.this.dns_name
}

output "alb_security_groups" {
  description = "List of security groups attached to the ALB."
  value       = aws_lb.this.security_groups
}

output "tenant_target_group_arns" {
  description = "Map of tenant‐key → corresponding target group ARN."
  value       = { for k, tg in aws_lb_target_group.tenant : k => tg.arn }
}

output "alb_name_prefix" {
  description = "Prefix used for naming ALB-related resources."
  value       = var.name_prefix
}
