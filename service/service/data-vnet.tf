provider "azurerm" {
  features {}
}

data "azurerm_resource_group" "example" {
  name = "my-resource-group"
}

data "azurerm_virtual_network" "example" {
  name                = "my-vnet"
  resource_group_name = data.azurerm_resource_group.example.name
}

data "azurerm_route_table" "example" {
  name                = "my-routetable"
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "subnet1"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "subnet2" {
  name                 = "subnet2"
  resource_group_name  = data.azurerm_resource_group.example.name
  virtual_network_name = data.azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet_route_table_association" "subnet1_routetable_association" {
  subnet_id      = azurerm_subnet.subnet1.id
  route_table_id = data.azurerm_route_table.example.id
}

resource "azurerm_subnet_route_table_association" "subnet2_routetable_association" {
  subnet_id      = azurerm_subnet.subnet2.id
  route_table_id = data.azurerm_route_table.example.id
}

resource "azurerm_network_security_group" "nsg" {
  name                = "my-nsg"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
}

resource "azurerm_web_app" "app" {
  name                = "my-webapp"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name

  server_farm_id = azurerm_app_service_plan.serverfarm.id
}

resource "azurerm_app_service_plan" "serverfarm" {
  name                = "my-serverfarm"
  location            = data.azurerm_resource_group.example.location
  resource_group_name = data.azurerm_resource_group.example.name
  sku {
    tier = "Standard"
    size = "S1"
  }
}
