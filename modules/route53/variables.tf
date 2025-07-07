variable "domain" {
  description = "The domain name for the hosted zone"
  type        = string
}

variable "short_name" {
  description = "The short name for the hosted zone"
  type        = string
}

variable "vpc_id" {
  description = "The ID of the VPC to associate with the hosted zone"
  type        = string
}

variable "vpc_name" {
  description = "The name of the VPC to associate with the hosted zone"
  type        = string
}

variable "interface_endpoints_ids" {
  description = "The interface endpoints to associate with the hosted zone"
  type = map(object({
    arn = string
    id  = string
  }))
  default = {}
}

variable "tags" {
  description = "The tags for the hosted zone"
  type        = map(string)
  default     = {}
}

variable "tenant_records" {
  description = "Map of DNS records to create under this zone"
  type = map(object({
    name    = string
    type    = string
    ttl     = optional(number, 300)
    records = optional(list(string), [])
    alias = optional(object({
      name                   = string
      zone_id                = string
      evaluate_target_health = bool
    }))
  }))
  default = {}
}

variable "shared_vpc_ids" {
  description = "List of VPC IDs to associate with this private hosted zone"
  type        = list(string)
  default     = []
}
