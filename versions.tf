terraform {
  # 1.9 is the first release whose input variable validations may reference other variables,
  # which the subnet overlap check relies on.
  required_version = ">= 1.9.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 5.12"
    }
  }
}
