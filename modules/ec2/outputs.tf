output "instance_ids" {
  description = "List of all EC2 instance IDs (one per for_each element)."
  value = [
    for inst in values(aws_instance.this) : inst.id
  ]
}

output "guardduty_detector_id" {
  description = "The GuardDuty detector ID (or null if enable_guardduty = false)."
  value       = var.enable_guardduty ? aws_guardduty_detector.this[0].id : null
}
