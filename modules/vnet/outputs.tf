output "vnet_id" {
  description = "Resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "Name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_location" {
  description = "Region the virtual network was created in."
  value       = azurerm_virtual_network.this.location
}

output "resource_group_name" {
  description = "Resource group containing the virtual network."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "address_space" {
  description = "Address space allocated to the virtual network."
  value       = azurerm_virtual_network.this.address_space
}
