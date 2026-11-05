variable "name" {
  description = "Name of the subnet."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the virtual network."
  type        = string
}

variable "virtual_network_name" {
  description = "Virtual network to create the subnet in."
  type        = string
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet. Must fall inside the virtual network address space and not overlap sibling subnets."
  type        = list(string)

  validation {
    condition     = length(var.address_prefixes) > 0 && alltrue([for cidr in var.address_prefixes : can(cidrhost(cidr, 0))])
    error_message = "address_prefixes must be a non-empty list of valid CIDR blocks, e.g. [\"10.0.1.0/24\"]."
  }
}

variable "network_security_group_id" {
  description = "NSG to associate with the subnet. Leave null to leave the subnet without an NSG."
  type        = string
  default     = null
}

variable "private_endpoint_network_policies" {
  description = <<-EOT
    Network policy enforcement for private endpoints in this subnet. Set it explicitly on any
    subnet holding private endpoints: the Azure default is Disabled, which bypasses the NSG.
  EOT
  type        = string
  default     = "Disabled"

  # The value is never null, so contains() can be called directly. An earlier null default here
  # made the validation itself fail: HCL evaluates both sides of || and contains(list, null) errors.
  validation {
    condition     = contains(["Disabled", "Enabled", "NetworkSecurityGroupEnabled", "RouteTableEnabled"], var.private_endpoint_network_policies)
    error_message = "private_endpoint_network_policies must be one of Disabled, Enabled, NetworkSecurityGroupEnabled, RouteTableEnabled."
  }
}

variable "delegations" {
  description = "Service delegations for the subnet, e.g. the AKS managed-subnet delegation."
  type = list(object({
    name    = string
    service = string
    actions = list(string)
  }))
  default = []
}
