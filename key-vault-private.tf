provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West US"
}

resource "azurerm_virtual_network" "example" {
  name                = "example-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "example-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_key_vault" "example" {
  name                        = "example-keyvault"
  resource_group_name         = azurerm_resource_group.example.name
  location                    = azurerm_resource_group.example.location
  sku_name                    = "standard"
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = true
  enable_soft_delete          = true
}

data "azurerm_client_config" "current" {}

resource "azurerm_private_dns_zone" "example" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  tags = {
    environment = "Production"
  }
}

resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-private-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = azurerm_private_dns_zone.example.name
  virtual_network_id    = azurerm_virtual_network.example.id
}

resource "azurerm_private_endpoint" "example" {
  name                      = "example-private-endpoint"
  resource_group_name       = azurerm_resource_group.example.name
  location                  = azurerm_resource_group.example.location
  subnet_id                 = azurerm_subnet.example.id
  private_service_connection {
    name                           = "example-private-service-connection"
    is_manual_connection           = false
    private_connection_resource_id = azurerm_key_vault.example.id
    subresource_names              = ["vault"]
  }
}

resource "azurerm_key_vault_network_acls" "example" {
  key_vault_id = azurerm_key_vault.example.id

  default_action = "Deny"

  bypass = [
    "AzureServices"
  ]

  ip_rules = [
    "x.x.x.x"  # Replace with your IP address or range
  ]

  virtual_network_subnet_ids = [
    azurerm_subnet.example.id
  ]
}

output "keyvault_endpoint" {
  value = azurerm_private_endpoint.example.private_service_connection.0.private_service_connection_state.0.endpoint
}
