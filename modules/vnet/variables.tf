variable "name" {
  description = "Name of the virtual network."
  type        = string
}

variable "location" {
  description = "Azure region to create the virtual network in."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the virtual network in."
  type        = string
}

variable "address_space" {
  description = "Address space of the virtual network as CIDR blocks."
  type        = list(string)

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "address_space must be a non-empty list of valid CIDR blocks, e.g. [\"10.0.0.0/16\"]."
  }
}

variable "tags" {
  description = "Tags applied to the virtual network."
  type        = map(string)
  default     = {}
}
