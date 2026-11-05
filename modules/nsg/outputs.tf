output "network_security_group_id" {
  description = "Resource ID of the network security group."
  value       = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  description = "Name of the network security group."
  value       = azurerm_network_security_group.this.name
}

output "rule_priorities" {
  description = "Priorities of the managed rules, for spotting collisions with Azure default rules."
  value       = [for rule in azurerm_network_security_rule.this : rule.priority]
}
