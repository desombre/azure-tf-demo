locals {
  common_tags = merge(
    {
      Environment = var.environment
      Project     = var.project
      Owner       = var.owner
      ManagedBy   = "terraform"
    },
    var.tags,
  )
}

resource "azurerm_resource_group" "network" {
  name     = var.resource_group_name
  location = var.location
  tags     = local.common_tags
}

module "vnet" {
  source = "./modules/vnet"

  name                = var.vnet_name
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  address_space       = var.address_space
  tags                = local.common_tags
}
