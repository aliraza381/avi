# Create VNET and Subnets for AVI Controller and SEs
resource "azurerm_virtual_network" "avi" {
  count      = var.create_networking ? 1 : 0
  name                = "${var.name_prefix}-avi-vnet"
  address_space       = [var.avi_cidr_block]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "avi" {
  count      = var.create_networking ? 1 : 0
  name                 = "${var.name_prefix}-avi-subnet"
  resource_group_name  = azurerm_resource_group.avi.name
  virtual_network_name = azurerm_virtual_network.avi[0].name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.avi[0].cidr_block, 8, 230 + each.key)]
}

resource "azurerm_network_interface" "avi" {
  count = var.controller_ha ? 3 : 1
  name                = "${var.name_prefix}-avi-controller-nic"
  location            = azurerm_resource_group.avi.location
  resource_group_name = azurerm_resource_group.avi.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.create_networking ? azurerm_subnet.avi[0].id : var.custom_subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}