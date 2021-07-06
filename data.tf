data "azurerm_subscription" "current" {
}
data "azurerm_client_config" "current" {
}
data "azurerm_subnet" "custom" {
  count                = var.create_networking == false ? 1 : 0
  name                 = var.custom_subnet_name
  virtual_network_name = var.custom_vnet_name
  resource_group_name  = var.custom_network_resource_group
}
data "azurerm_virtual_network" "peer" {
  count               = var.create_vnet_peering == true ? 1 : 0
  name                = var.vnet_peering_settings.vnet_name
  resource_group_name = var.vnet_peering_settings.resource_group
}