variable "capacity" {
  description = "Capacity of the firewall"
  type        = number
  default     = 100
  validation {
    condition     = var.capacity > 1
    error_message = "The capacity must be greater than 1."
  }

}

variable "allowed_domains" {
  description = "List of allowed domains"
  type        = list(string)
}

variable "home_net_cidrs" {
  description = "List of CIDRs for the home network"
  type        = list(string)
}

variable "name_prefix" {
  description = "Prefix for resource names"
  type        = string
}

variable "enable_http_host" {
  description = "Enable HTTP host"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Key-value map of tags for the permission set"
  type        = map(string)
  default     = {}
}
