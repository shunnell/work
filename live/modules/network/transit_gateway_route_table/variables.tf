variable "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  type        = string
  default     = ""
}

variable "name" {
  description = "Name of the Transit Gateway Route Table"
  type        = string
  default     = ""
}

variable "transit_gateway_attachment_id" {
  description = "ID of the Transit Gateway Attachment"
  type        = string
  default     = ""
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}
