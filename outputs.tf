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

output "aks_subnet_id" {
  description = "Resource ID of the AKS subnet — pass it to azurerm_kubernetes_network_profile.subnet_id in issue #7."
  value       = module.aks_subnet.subnet_id
}

output "aks_subnet_name" {
  description = "Name of the AKS subnet."
  value       = module.aks_subnet.subnet_name
}

output "private_endpoints_subnet_id" {
  description = "Resource ID of the private endpoints subnet — target for subnet_id in issue #4 private endpoints."
  value       = module.private_endpoints_subnet.subnet_id
}

output "private_endpoints_subnet_name" {
  description = "Name of the private endpoints subnet."
  value       = module.private_endpoints_subnet.subnet_name
}

output "private_endpoints_nsg_id" {
  description = "Resource ID of the NSG guarding the private endpoints subnet."
  value       = module.private_endpoints_nsg.network_security_group_id
}

output "private_endpoints_subnet_nsg_id" {
  description = "NSG attached to the private endpoints subnet as Azure reports it — should equal private_endpoints_nsg_id."
  value       = module.private_endpoints_subnet.associated_network_security_group_id
}
