variable "vpc_id" {
  type = string
}

variable "name" {
  type = string
}

variable "availability_zones" {
  description = "Availability zones in which this VPC will create subnets"
  type        = set(string)
  validation {
    condition     = length(var.availability_zones) > 0
    error_message = "At least one AZ must be specified"
  }
  validation {
    condition     = length(toset(var.availability_zones)) == length(var.availability_zones)
    error_message = "AZ names must be unique"
  }
  validation {
    condition     = alltrue([for v in var.availability_zones : startswith(v, data.aws_region.current.name)])
    error_message = "AZs must all be in the current region"
  }
}

# TODO remove this if or when all VPCs are imported and converted to use automatic addressing via subnet_width.
variable "force_cidr_ranges" {
  description = "Should not normally be set. Overrides subnet-width-based selection of CIDR ranges for subnets. Map of AZ => CIDR."
  type        = map(string)
  default     = {}
  validation {
    condition     = length(var.force_cidr_ranges) == 0 || toset(keys(var.force_cidr_ranges)) == var.availability_zones
    error_message = "CIDR ranges must match availability_zones"
  }
}

variable "width" {
  type = number
  validation {
    condition     = var.width > 2
    error_message = "Width must be at least 2"
  }
}

variable "offset" {
  type = number
  validation {
    condition     = var.offset >= 0
    error_message = "Must be >= 0"
  }
}

variable "tier" {
  type        = string
  default     = "private"
  description = "'tier' in which subnets will be placed. Should not ordinarily be set."
  validation {
    condition     = contains(["private", "public"], lower(var.tier))
    error_message = "Must be 'private' or 'public'"
  }
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
  validation {
    condition     = !contains(keys(var.tags), "Name") && !contains(keys(var.tags), "name")
    error_message = "'name' tag is not allowed"
  }
  validation {
    condition     = !contains(keys(var.tags), "Tier") && !contains(keys(var.tags), "tier")
    error_message = "'tier' tag is not allowed"
  }
}
