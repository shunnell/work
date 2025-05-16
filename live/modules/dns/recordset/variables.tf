variable "domain" {
  description = "Domain of this recordset. A hostname of foo.bar.baz has a domain of 'baz'."
  type        = string
  validation {
    condition     = length(var.domain) > 2 && length(var.domain) < 32
    error_message = "Must have a value"
  }
}

variable "description" {
  description = "Human-readable description of this recordset and its hosted zone"
  type        = string
  validation {
    condition     = length(var.description) > 0 && length(var.description) < 128
    error_message = "Must have a value"
  }
}

variable "a_records" {
  description = "Basic, non-alias 'A' records to be created in this recordset. Keys are hostnames (without the domain), values are lists of IP addresses (to create basic A records) or hostnames (to create alias records)."
  type        = map(list(string))
  default     = {}
  validation {
    condition     = alltrue([for k in keys(var.a_records) : !(endswith(k, var.domain) || startswith(k, ".") || endswith(k, "."))])
    error_message = "Keys must be hostnames without the domain"
  }
  validation {
    condition     = alltrue([for v in flatten(values(var.a_records)) : can(cidrnetmask("${v}/32"))])
    error_message = "Values must be IP addresses"
  }
}

variable "alias_records" {
  description = "Alias 'A' records to be created in this recordset. Keys are hostnames (without the domain), values are maps containing zone_id, name, and evaluate_target_health"
  type = map(object({
    zone_id                = string
    name                   = string
    evaluate_target_health = optional(string, false)
  }))
  default = {}
}

variable "cname_records" {
  description = "'CNAME' records to be created in this recordset. Keys are hostnames (without the domain), values are other DNS locations."
  type        = map(string)
  default     = {}
  validation {
    condition     = !anytrue([for k in keys(var.cname_records) : (endswith(k, var.domain) || startswith(k, ".") || endswith(k, "."))])
    error_message = "Keys must be hostnames without the domain"
  }
}

variable "vpc_associations" {
  description = "List of VPCs to which to provide private DNS for this recordset. The FIRST item in this list will be used as the primary VPC/owner VPC of the created hosted zone. If 'null', a public, internet-available hosted zone will be created. Set this to 'null' with extreme care and prior approval from platform team lead engineering."
  type        = list(string) # DO NOT change this to a set, the order is important.
  default     = []
}

variable "tags" {
  description = "Tags to apply to all resources"
  type        = map(string)
  default     = {}
}
