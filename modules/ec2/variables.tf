variable "ami" {
  description = "The AMI ID to use for the instance"
  type        = string
}

variable "instance_type" {
  description = "The type of instance to create"
  type        = string
}

variable "key_name" {
  description = "The name of the key pair to use for SSH access"
  type        = string
}

variable "subnet_id" {
  description = "The ID of the subnet to launch the instance in"
  type        = string
}

variable "monitoring" {
  description = "Enable detailed monitoring"
  type        = bool
  default     = false
}

variable "ec2_instance_profile" {
  description = "IAM instance profile for the EC2 instance"
  type        = string
}

variable "tags" {
  description = "Tags to assign to the instance"
  type        = map(string)
  default     = {}
}

variable "instance_name" {
  description = "The name of the EC2 instance"
  type        = string
}