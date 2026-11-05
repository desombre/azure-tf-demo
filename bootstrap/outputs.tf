output "resource_group_name" {
  description = "Resource group containing the state storage account."
  value       = azurerm_resource_group.state.name
}

output "storage_account_name" {
  description = "Storage account Terraform writes state blobs to."
  value       = azurerm_storage_account.state.name
}

output "container_name" {
  description = "Blob container holding the state files."
  value       = azurerm_storage_container.state.name
}

output "blob_endpoint" {
  description = "Data plane endpoint the backend will use."
  value       = azurerm_storage_account.state.primary_blob_endpoint
}

output "container_scope" {
  description = "Container-scoped RBAC resource path used for the Storage Blob Data Contributor assignments."
  value       = one(azurerm_role_assignment.state_contributors[*].scope)
}

output "backend_values" {
  description = "Copy these into env/<environment>/backend.hcl."
  value = {
    resource_group_name  = azurerm_resource_group.state.name
    storage_account_name = azurerm_storage_account.state.name
    container_name       = azurerm_storage_container.state.name
  }
}
