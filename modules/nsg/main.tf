resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  # Rules are separate azurerm_network_security_rule resources. Inline security_rule blocks
  # would make this resource authoritative over every rule, conflicting with rules managed
  # outside Terraform and forcing an NSG-wide replace to change one rule.
}

resource "azurerm_network_security_rule" "this" {
  for_each = { for rule in var.rules : rule.name => rule }

  name                        = each.value.name
  network_security_group_name = azurerm_network_security_group.this.name
  resource_group_name         = var.resource_group_name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol

  source_port_range            = each.value.source_port_range
  source_address_prefix        = each.value.source_address_prefix
  source_address_prefixes      = each.value.source_address_prefixes
  destination_port_range       = each.value.destination_port_range
  destination_port_ranges      = each.value.destination_port_ranges
  destination_address_prefix   = each.value.destination_address_prefix
  destination_address_prefixes = each.value.destination_address_prefixes
}
