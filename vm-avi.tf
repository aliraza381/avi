locals {
  cloud_settings = {
    subscription_id     = data.azurerm_subscription.current.subscription_id
    se_mgmt_subnet_name = var.create_networking ? azurerm_subnet.avi[0].name : var.custom_subnet_id
    se_vnet_id_path     = var.create_networking ? azurerm_virtual_network.avi[0].id : var.custom_vnet_id
    region              = var.region
    avi_version         = var.avi_version
    se_vm_size          = var.se_vm_size
    use_azure_dns       = var.use_azure_dns
    se_resource_group   = var.create_resource_group ? azurerm_resource_group.avi[0].name : var.custom_se_resource_group
    se_name_prefix      = var.name_prefix
    controller_ip       = local.controller_ip
    controller_names    = local.controller_names
    controller_ha       = var.controller_ha
    controller_name_1   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[0].name : null
    controller_ip_1     = var.controller_ha ? azurerm_network_interface.avi[0].private_ip_address : null
    controller_name_2   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[1].name : null
    controller_ip_2     = var.controller_ha ? azurerm_network_interface.avi[1].private_ip_address : null
    controller_name_3   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[2].name : null
    controller_ip_3     = var.controller_ha ? azurerm_network_interface.avi[2].private_ip_address : null
  }
  region           = replace(var.region, " ", "-")
  controller_ip    = azurerm_linux_virtual_machine.avi_controller[*].private_ip_address
  controller_names = azurerm_linux_virtual_machine.avi_controller[*].name
}
resource "azurerm_marketplace_agreement" "avi" {
  publisher = "avi-networks"
  offer     = "avi-vantage-adc"
  plan      = "avi-vantage-adc-2001"
}
resource "azurerm_linux_virtual_machine" "avi_controller" {
  count                           = var.controller_ha ? 3 : 1
  name                            = "${var.name_prefix}-avi-controller-${count.index + 1}"
  resource_group_name             = var.create_resource_group ? azurerm_resource_group.avi[0].name : var.custom_controller_resource_group
  location                        = azurerm_resource_group.avi[0].location
  size                            = var.controller_vm_size
  admin_username                  = "avi-admin"
  admin_password                  = "Password123!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.avi[count.index].id,
  ]
  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "avi-networks"
    offer     = "avi-vantage-adc"
    sku       = "avi-vantage-adc-2001"
    version   = "latest"
  }
  plan {
    name      = "avi-vantage-adc-2001"
    publisher = "avi-networks"
    product   = "avi-vantage-adc"
  }
  tags = var.custom_tags

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = var.root_disk_size
  }
  provisioner "local-exec" {
    command = "bash ${path.module}/files/change-controller-password.sh --controller-address \"${azurerm_public_ip.avi[0].ip_address}\" --current-password \"${var.controller_default_password}\" --new-password \"${var.controller_password}\""
  }
  depends_on = [
    azurerm_marketplace_agreement.avi,
    azurerm_public_ip.avi
  ]
}
resource "null_resource" "ansible_provisioner" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    controller_instance_ids = join(",", azurerm_linux_virtual_machine.avi_controller.*.id)
  }

  connection {
    type     = "ssh"
    host     = azurerm_public_ip.avi[0].ip_address
    user     = "admin"
    timeout  = "600s"
    password = var.controller_password
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/avi-controller-azure-all-in-one-play.yml.tpl",
    local.cloud_settings)
    destination = "/home/admin/avi-controller-azure-all-in-one-play.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "ansible-playbook avi-controller-azure-all-in-one-play.yml -e password=${var.controller_password} -e azure_app_id=\"${azuread_application.avi[0].application_id}\" -e azure_auth_token=\"${random_password.sp.result}\" -e azure_tenant_id=\"${data.azurerm_client_config.current.tenant_id}\"  > ansible-playbook.log 2> ansible-error.log",
      "echo Controller Configuration Completed"
    ]
  }
}