provider "azurerm" {
  features {}

  subscription_id = var.subscription_id

  # Required because the state account below disables shared access keys: without this the
  # provider would try to create the container with Shared Key auth and fail at apply time.
  storage_use_azuread = true
}

resource "azurerm_resource_group" "state" {
  name     = var.resource_group_name
  location = var.location
  tags = merge(local.common_tags, {
    Role = "terraform-state"
  })
}

resource "azurerm_storage_account" "state" {
  name                = var.storage_account_name
  resource_group_name = azurerm_resource_group.state.name
  location            = azurerm_resource_group.state.location
  account_tier        = "Standard"
  account_kind        = "StorageV2"
  # The provider's ValidateFunc for this field is case-sensitive, so the value is normalised
  # here rather than trusting the caller's casing.
  account_replication_type = upper(var.replication_type)

  min_tls_version            = "TLS1_2"
  https_traffic_only_enabled = true

  # Anonymous blob access is off, but the account stays publicly reachable on purpose: the
  # state account has to be contactable before issue #4 builds private endpoints. Tightening
  # this to a private endpoint is the follow-up, not an oversight.
  public_network_access           = "Enabled"
  allow_nested_items_to_be_public = false

  # Access keys are disabled so the backend authenticates with Entra ID + RBAC. There is then
  # no storage credential to keep in Key Vault, which supersedes the account-key assumption in
  # issue #1. Set shared_access_key_enabled back to true only if you genuinely need SAS tokens.
  shared_access_key_enabled        = false
  default_to_oauth_authentication  = true
  cross_tenant_replication_enabled = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = var.retention_days
    }

    container_delete_retention_policy {
      days = var.retention_days
    }
  }

  tags = local.common_tags
}

resource "azurerm_storage_container" "state" {
  name                  = var.container_name
  storage_account_id    = azurerm_storage_account.state.id
  container_access_type = "private"
}

# The identity that runs Terraform needs Storage Blob Data Contributor on the container.
# Add the CI workload identity's object ID here (issue #8 owns who that identity is).
resource "azurerm_role_assignment" "state_contributors" {
  for_each = toset(var.contributor_principal_ids)

  scope                = "${azurerm_storage_account.state.id}/blobServices/default/containers/${azurerm_storage_container.state.name}"
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = each.value
  description          = "Read and write Terraform state blobs in the ${var.container_name} container."
}
