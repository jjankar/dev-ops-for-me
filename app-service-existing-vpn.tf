# Define the Azure provider
provider "azurerm" {
  features {}
}

# Define the existing Virtual Network and Subnet
data "azurerm_subnet" "existing" {
  name                 = "existing-subnet"
  virtual_network_name = "existing-virtual-network"
  resource_group_name  = "existing-resource-group"
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "example-resource-group"
  location = "West US"
}

# Create an Azure App Service Plan
resource "azurerm_app_service_plan" "example" {
  name                = "example-app-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}

# Create an Azure App Service
resource "azurerm_app_service" "example" {
  name                = "example-app-service"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    always_on                = true
    dotnet_framework_version = "v5.0"
  }

  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE" = "1"
  }
}

# Create a private endpoint for the Azure App Service
resource "azurerm_private_endpoint" "example" {
  name                = "example-private-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = data.azurerm_subnet.existing.id

  private_service_connection {
    name                           = "example-private-connection"
    private_connection_resource_id = azurerm_app_service.example.id
    subresource_names              = ["sites"]
  }
}

# Create a private DNS zone virtual network link
resource "azurerm_private_dns_zone_virtual_network_link" "example" {
  name                  = "example-private-dns-link"
  resource_group_name   = azurerm_resource_group.example.name
  private_dns_zone_name = "privatelink.azurewebsites.net"
  virtual_network_id    = data.azurerm_subnet.existing.virtual_network_id
}
