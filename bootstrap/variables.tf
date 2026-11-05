variable "subscription_id" {
  description = "Subscription that will host the state storage account. Leave unset to fall back to ARM_SUBSCRIPTION_ID."
  type        = string
  default     = null

  validation {
    condition     = var.subscription_id == null || can(regex("^[0-9a-fA-F]{8}(-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}$", var.subscription_id))
    error_message = "subscription_id must be a GUID, e.g. \"00000000-0000-0000-0000-000000000000\"."
  }
}

variable "environment" {
  description = "Environment this state backend belongs to, e.g. \"dev\" or \"prod\"."
  type        = string
}

variable "location" {
  description = "Azure region for the state resource group and storage account."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group holding the state storage account. Keep it separate from workload resource groups."
  type        = string
}

variable "storage_account_name" {
  description = "Globally unique storage account name — 3 to 24 lowercase letters and digits, no hyphens."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name must be 3-24 characters of lowercase letters and digits only (globally unique across Azure)."
  }
}

variable "container_name" {
  description = "Blob container holding state files."
  type        = string
  default     = "tfstate"
}

variable "retention_days" {
  description = "Soft-delete retention in days for blobs and containers, giving a recovery window for damaged state."
  type        = number
  default     = 30

  validation {
    condition     = var.retention_days >= 1 && var.retention_days <= 365
    error_message = "retention_days must be between 1 and 365."
  }
}

variable "replication_type" {
  description = "Storage replication for state. LRS is usually enough; ZRS/GRS add durability for prod."
  type        = string
  default     = "LRS"

  # Mirrors the provider's own ValidateFunc set. RA_GRS is the Azure REST API name, not the
  # provider's — azurerm rejects it and expects RAGZRS instead.
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], upper(var.replication_type))
    error_message = "replication_type must be one of LRS, ZRS, GRS, RAGRS, GZRS, RAGZRS."
  }
}

variable "contributor_principal_ids" {
  description = "Object IDs (Entra ID principals) granted Storage Blob Data Contributor on the state container, e.g. the CI workload identity."
  type        = list(string)
  default     = []
}

variable "project" {
  description = "Value of the Project tag."
  type        = string
  default     = "azure-tf-demo"
}

variable "owner" {
  description = "Value of the Owner tag."
  type        = string
}

variable "tags" {
  description = "Extra tags merged over the built-in environment/project/owner tags."
  type        = map(string)
  default     = {}
}
