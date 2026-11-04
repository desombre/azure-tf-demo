provider "azurerm" {
  features {}

  # Unset (null) falls back to ARM_SUBSCRIPTION_ID; per-environment tfvars pin it explicitly.
  subscription_id = var.subscription_id
}
