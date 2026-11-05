variable "name" {
  description = "Name of the network security group."
  type        = string
}

variable "location" {
  description = "Azure region to create the network security group in."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group to create the network security group in."
  type        = string
}

variable "rules" {
  description = <<-EOT
    Security rules for the group. Exactly one of source_address_prefix / source_address_prefixes
    and one of destination_port_range / destination_port_ranges should be set per rule.
  EOT
  type = list(object({
    name                         = string
    priority                     = number
    direction                    = string
    access                       = string
    protocol                     = string
    source_port_range            = optional(string)
    source_address_prefix        = optional(string)
    source_address_prefixes      = optional(list(string))
    destination_port_range       = optional(string)
    destination_port_ranges      = optional(list(string))
    destination_address_prefix   = optional(string)
    destination_address_prefixes = optional(list(string))
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.rules : r.priority >= 100 && r.priority <= 4096])
    error_message = "Rule priorities must be between 100 and 4096."
  }

  validation {
    condition     = length(var.rules) == length(distinct([for r in var.rules : r.priority]))
    error_message = "Rule priorities must be unique within the network security group."
  }

  validation {
    condition     = length(var.rules) == length(distinct([for r in var.rules : r.name]))
    error_message = "Rule names must be unique within the network security group."
  }
}

variable "tags" {
  description = "Tags applied to the network security group."
  type        = map(string)
  default     = {}
}
