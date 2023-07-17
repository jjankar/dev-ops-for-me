# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Define variables
variable "key_vault_name" {
  description = "Name of the Azure Key Vault"
  type        = string
  default     = "my-key-vault"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
  default     = "my-resource-group"
}

variable "location" {
  description = "Azure region where the Key Vault will be created"
  type        = string
  default     = "eastus"
}

variable "access_policies" {
  description = "List of access policies for the Key Vault"
  type        = list(object({
    tenant_id          = string
    object_id          = string
    secret_permissions = list(string)
  }))
  default     = [
    {
      tenant_id          = "<tenant-id>"
      object_id          = "<object-id>"
      secret_permissions = ["get", "list", "set", "delete"]
    }
  ]
}

# Create the resource group
resource "azurerm_resource_group" "example" {
  name     = var.resource_group_name
  location = var.location
}

# Create the Azure Key Vault
resource "azurerm_key_vault" "example" {
  name                        = var.key_vault_name
  resource_group_name         = azurerm_resource_group.example.name
  location                    = var.location
  enabled_for_disk_encryption = true
  tenant_id                   = var.access_policies[0].tenant_id

  sku {
    name = "standard"
  }

  access_policy {
    tenant_id = var.access_policies[0].tenant_id
    object_id = var.access_policies[0].object_id

    secret_permissions = var.access_policies[0].secret_permissions
  }
}
