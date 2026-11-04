resource "azurerm_virtual_network" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.address_space
  tags                = var.tags

  # Subnets are managed as standalone azurerm_subnet resources (issue #9), not inline
  # subnet {} blocks — inline blocks fight any out-of-band subnet owner such as AKS.
}
