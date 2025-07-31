variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "tenant_name" {
  description = "Name of the tenant - for namespace and other resources"
  type        = string
}

variable "cluster_issuer" {
  description = "CA certificate issure"
  type        = string
}

variable "gateway_class_name" {
  description = "Name of the GatewayClass"
  type        = string
}

variable "tenant_domain_names" {
  description = "Domain names for tenant traffic. Ex: data-platform.dev.cloud-city, or iva.test.cloud-city"
  type        = map(string)
  validation {
    error_message = "Must provide a set of domain names."
    condition = length(keys(var.tenant_domain_names)) > 0 && alltrue([
      for n, d in var.tenant_domain_names : length(try(regex("^[[:alnum:]\\-]+$", n), "")) > 0 && length(try(regex("^[[:alnum:]][\\w\\-\\.]+[[:alnum:]]$", d), "")) > 0
    ])
  }
}

variable "web_port" {
  description = "Port for insecure inbound traffic (8000). This comes from the gateway api port, not the exposed service port"
  type        = number
  validation {
    error_message = "Provide a proper port number"
    condition     = var.web_port > 0
  }
}

variable "websecure_port" {
  description = "Port for secure inbound traffic (8443). This comes from the gateway api port, not the exposed service port"
  type        = number
  validation {
    error_message = "Provide a proper port number"
    condition     = var.websecure_port > 0
  }
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
