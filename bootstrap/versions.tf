terraform {
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.12"
    }
  }

  # Explicitly local: this stack creates the storage account that every other stack uses as
  # its backend, so it cannot store its own state inside that account.
  backend "local" {}
}
