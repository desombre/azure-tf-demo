resource "azurerm_subnet" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes

  # Azure defaults this to Disabled, which silently exempts private endpoint NICs from NSG
  # and route table evaluation. The caller sets it explicitly so the NSG really filters.
  private_endpoint_network_policies = var.private_endpoint_network_policies

  dynamic "delegation" {
    for_each = var.delegations
    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service
        actions = delegation.value.actions
      }
    }
  }
}

resource "azurerm_subnet_network_security_group_association" "this" {
  count = var.network_security_group_id == null ? 0 : 1

  subnet_id                 = azurerm_subnet.this.id
  network_security_group_id = var.network_security_group_id
}
