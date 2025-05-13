variable "env" {
  description = "Environment name (e.g. dev, prod)"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "vnet_address_space" {
  description = "CIDR block(s) for the VNet"
  type        = list(string)
}

variable "subnet_names" {
  description = "List of subnet names to create"
  type        = list(string)
}
