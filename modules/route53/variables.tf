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
