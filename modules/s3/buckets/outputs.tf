output "buckets" {
  description = "The collection of buckets"
  value       = concat(module.buckets_with_global_name[*], module.buckets_with_prefix[*])
}
