variable "zone_name" {
  description = "The DNS name for the hosted zone (no trailing dot)."
  type        = string
}

variable "private_zone" {
  description = "Create a private hosted zone if true, otherwise public."
  type        = bool
  default     = false
}

variable "vpc_ids" {
  description = "List of VPC IDs to associate the private zone with. If empty or private_zone=false, no associations are made."
  type        = list(string)
  default     = []
}

variable "vpc_region" {
  description = "The AWS region of the VPCs to associate (only used if private_zone=true)."
  type        = string
  default     = ""
}

variable "comment" {
  description = "Comment for the hosted zone."
  type        = string
  default     = null
}

variable "tags" {
  description = "A map of tags to assign to the hosted zone."
  type        = map(string)
  default     = {}
}
