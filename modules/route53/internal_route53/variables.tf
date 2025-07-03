variable "zone_name" {
  description = "The DNS name for the hosted zone (no trailing dot)."
  type        = string
}

variable "vpc_ids" {
  description = "List of VPC IDs to associate the private zone with."
  type        = list(string)
}

variable "vpc_region" {
  description = "The AWS region of the VPCs to associate."
  type        = string
}

variable "comment" {
  description = "Comment for the hosted zone."
  type        = string
}

variable "tags" {
  description = "A map of tags to assign to the hosted zone."
  type        = map(string)
  default     = {}
}
