variable "subscription_id" {
  description = "Subscription to deploy into. Leave unset to fall back to ARM_SUBSCRIPTION_ID."
  type        = string
  default     = null

  validation {
    condition     = var.subscription_id == null || can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a GUID, e.g. \"00000000-0000-0000-0000-000000000000\"."
  }
}

variable "environment" {
  description = "Environment this stack belongs to, e.g. \"dev\" or \"prod\". Written to the Environment tag."
  type        = string
}

variable "location" {
  description = "Azure region for the resource group and virtual network, e.g. \"westeurope\"."
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group hosting the virtual network."
  type        = string
}

variable "vnet_name" {
  description = "Name of the virtual network."
  type        = string
}

variable "address_space" {
  description = "Address space of the virtual network as CIDR blocks, sized to hold every planned subnet."
  type        = list(string)
  default     = ["10.0.0.0/16"]

  validation {
    condition     = length(var.address_space) > 0 && alltrue([for cidr in var.address_space : can(cidrhost(cidr, 0))])
    error_message = "address_space must be a non-empty list of valid CIDR blocks, e.g. [\"10.0.0.0/16\"]."
  }
}

variable "project" {
  description = "Value of the Project tag."
  type        = string
  default     = "azure-tf-demo"
}

variable "owner" {
  description = "Value of the Owner tag — the person or team accountable for these resources."
  type        = string
}

variable "tags" {
  description = "Extra tags merged over the built-in environment/project/owner tags."
  type        = map(string)
  default     = {}
}
