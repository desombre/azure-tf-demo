output "subnet_id" {
  description = "Resource ID of the subnet."
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Name of the subnet."
  value       = azurerm_subnet.this.name
}

output "virtual_network_name" {
  description = "Virtual network the subnet belongs to."
  value       = azurerm_subnet.this.virtual_network_name
}

output "address_prefixes" {
  description = "Address prefixes allocated to the subnet."
  value       = azurerm_subnet.this.address_prefixes
}

output "associated_network_security_group_id" {
  description = "NSG currently attached to the subnet, read back from Azure. Null when no association is managed."
  value       = azurerm_subnet.this.network_security_group_id
}
