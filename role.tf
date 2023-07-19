provider "azurerm" {
  features {}
}

data "azurerm_user" "example" {
  user_principal_name = "<user_principal_name>"
}

resource "azurerm_role_assignment" "example" {
  scope              = "/subscriptions/<subscription_id>/resourceGroups/<resource_group_name>"
  role_definition_id = "/subscriptions/<subscription_id>/providers/Microsoft.Authorization/roleDefinitions/<role_definition_id>"
  principal_id       = data.azurerm_user.example.id
}
