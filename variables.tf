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

variable "aks_subnet_name" {
  description = "Name of the subnet that hosts AKS node pools."
  type        = string
  default     = "snet-aks"
}

variable "aks_subnet_address_prefixes" {
  description = "Address prefixes for the AKS subnet, carved out of the virtual network address space."
  type        = list(string)
  default     = ["10.0.1.0/24"]

  validation {
    condition     = length(var.aks_subnet_address_prefixes) > 0 && alltrue([for cidr in var.aks_subnet_address_prefixes : can(cidrhost(cidr, 0))])
    error_message = "aks_subnet_address_prefixes must be a non-empty list of valid CIDR blocks, e.g. [\"10.0.1.0/24\"]."
  }

  validation {
    condition     = length(setintersection(toset(var.aks_subnet_address_prefixes), toset(var.private_endpoints_subnet_address_prefixes))) == 0
    error_message = "aks_subnet_address_prefixes and private_endpoints_subnet_address_prefixes must not share a prefix."
  }
}

variable "aks_subnet_delegation_enabled" {
  description = "Delegate the AKS subnet to Microsoft.ContainerService/ManagedClusters. Required for Azure CNI managed-subnet clusters; the delegation reserves the subnet for AKS."
  type        = bool
  default     = true
}

variable "private_endpoints_subnet_name" {
  description = "Name of the subnet holding private endpoint NICs."
  type        = string
  default     = "snet-private-endpoints"
}

variable "private_endpoints_subnet_address_prefixes" {
  description = "Address prefixes for the private endpoints subnet, carved out of the virtual network address space."
  type        = list(string)
  default     = ["10.0.2.0/24"]

  validation {
    condition     = length(var.private_endpoints_subnet_address_prefixes) > 0 && alltrue([for cidr in var.private_endpoints_subnet_address_prefixes : can(cidrhost(cidr, 0))])
    error_message = "private_endpoints_subnet_address_prefixes must be a non-empty list of valid CIDR blocks, e.g. [\"10.0.2.0/24\"]."
  }
}

variable "private_endpoints_nsg_name" {
  description = "Name of the network security group guarding the private endpoints subnet."
  type        = string
  default     = "nsg-private-endpoints"
}

variable "private_endpoints_subnet_network_policies" {
  description = <<-EOT
    How private endpoint NIC traffic in the private endpoints subnet is filtered.
    NetworkSecurityGroupEnabled routes it through the NSG without needing route tables.
    Azure's own default, Disabled, would exempt private endpoints from the NSG entirely.
  EOT
  type        = string
  default     = "NetworkSecurityGroupEnabled"

  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoints_subnet_network_policies)
    error_message = "private_endpoints_subnet_network_policies must be one of Disabled, Enabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
  }
}

variable "pe_nsg_extra_rules" {
  description = <<-EOT
    Additional security rules for the private endpoints NSG, appended to the built-in
    Private Link rules. Custom rules must use priority 200 or higher; 100-199 are reserved.
    Set exactly one of source_address_prefix / source_address_prefixes and one of
    destination_port_range / destination_port_ranges per rule.
  EOT
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string, "*")
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    destination_address_prefix   = optional(string, "*")
    destination_address_prefixes = optional(list(string))
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.pe_nsg_extra_rules : r.priority >= 200 && r.priority <= 4096])
    error_message = "pe_nsg_extra_rules priorities must be 200-4096; 100-199 are reserved for the built-in Private Link rules."
  }

  validation {
    condition     = length(var.pe_nsg_extra_rules) == length(distinct([for r in var.pe_nsg_extra_rules : r.name]))
    error_message = "pe_nsg_extra_rules names must be unique."
  }

  validation {
    condition     = length(var.pe_nsg_extra_rules) == length(distinct([for r in var.pe_nsg_extra_rules : r.priority]))
    error_message = "pe_nsg_extra_rules priorities must be unique."
  }
}
