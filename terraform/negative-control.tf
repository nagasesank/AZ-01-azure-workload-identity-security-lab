resource "azurerm_user_assigned_identity" "negative_control_canary" {
  name                = "id-az01-negative-control-canary"
  resource_group_name = azurerm_resource_group.negative_control.name
  location            = azurerm_resource_group.negative_control.location
  tags                = local.project_tags
}
