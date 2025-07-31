output "load_balancer_name" {
  description = "The name of the Load Balancer"
  value       = aws_lb.load_balancer.name
}

output "load_balancer_type" {
  description = "The type of the Load Balancer - used in k8s lb service annotations"
  value       = local.lb_type
}

output "load_balancer_arn" {
  description = "The ARN of the Load Balancer"
  value       = aws_lb.load_balancer.arn
}

output "load_balancer_dns" {
  description = "The DNS of the Load Balance"
  value       = aws_lb.load_balancer.dns_name
}

output "load_balancer_zone_id" {
  description = "Canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = aws_lb.load_balancer.zone_id
}

output "load_balancer_target_groups" {
  description = "The target groups for the Load Balancer"
  value = {
    # using the last bit after '/' in the arn name - useful for auto-replacing items that use the target group
    for tg in aws_lb_target_group.tg : "${tg.name}-${substr(tg.arn, -16, -1)}" => {
      arn  = tg.arn
      port = tg.port
      type = tg.target_type
    }
  }
}

output "load_balancer_security_group_id" {
  description = "ID of the Security Group for the Load Balancer"
  value       = module.lb_sg.id
}

output "load_balancer_security_group_arn" {
  description = "ARN of the Security Group for the Load Balancer"
  value       = module.lb_sg.arn
}

output "load_balancer_subnet_mappings" {
  description = "Subnet mappings for the Load Balancer"
  value       = aws_lb.load_balancer.subnet_mapping
}
