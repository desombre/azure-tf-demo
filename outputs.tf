output "resource_group_name" {
  description = "Resource group hosting the virtual network."
  value       = azurerm_resource_group.network.name
}

output "vnet_id" {
  description = "Resource ID of the virtual network — reference this from subnet and private-endpoint resources."
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network, for azurerm_subnet's virtual_network_name."
  value       = module.vnet.vnet_name
}

output "vnet_location" {
  description = "Region of the virtual network."
  value       = module.vnet.vnet_location
}

output "address_space" {
  description = "Address space allocated to the virtual network."
  value       = module.vnet.address_space
}
