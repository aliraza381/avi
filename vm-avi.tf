locals {
  # AKO Settings
  cloud_settings = {
    subscription_id     = data.azurerm_subscription.current.id
    se_mgmt_subnet_name = var.create_networking ? azurerm_subnet.avi[0].id : var.custom_subnet_id
    se_vnet_id_path     = var.create_networking ? azurerm_virtual_network.avi[0].id : var.custom_vnet_id
    region              = var.region
    se_vm_size          = var.se_vm_size
    use_azure_dns       = var.use_azure_dns
    se_resource_group   = var.create_resource_group ? azurerm_resource_group.avi[0].name : var.custom_se_resource_group
    controller_version  = var.controller_version
    se_name_prefix      = var.name_prefix
    controller_ha       = var.controller_ha
    controller_name_1   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[0].name : null
    controller_ip_1     = var.controller_ha ? azurerm_network_interface.avi[0].private_ip_address : null
    controller_name_2   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[1].name : null
    controller_ip_2     = var.controller_ha ? azurerm_network_interface.avi[1].private_ip_address : null
    controller_name_3   = var.controller_ha ? azurerm_linux_virtual_machine.avi_controller[2].name : null
    controller_ip_3     = var.controller_ha ? azurerm_network_interface.avi[2].private_ip_address : null
  }
}

resource "azurerm_linux_virtual_machine" "avi_controller" {
  count                           = var.controller_ha ? 3 : 1
  name                            = "${var.name_prefix}-avi-controller-${count.index + 1}"
  resource_group_name             = var.create_resource_group ? azurerm_resource_group.avi[0].name : var.custom_controller_resource_group
  location                        = azurerm_resource_group.avi[0].location
  size                            = var.controller_vm_size
  admin_username                  = "admin"
  admin_password                  = var.controller_password
  disable_password_authentication = true
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
  tags = var.custom_tags

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
    disk_size_gb         = var.root_disk_size
  }
  provisioner "local-exec" {
    command = "bash ${path.module}/files/change-controller-password.sh --controller-address \"${azurerm_public_ip.avi[0].ip_address}\" --current-password \"${var.controller_default_password}\" --new-password \"${var.controller_password}\""
  }
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
      "sleep 180",
      "sudo /opt/avi/scripts/initialize_admin_user.py --password ${var.controller_password}",
      "ansible-playbook avi-controller-azure-all-in-one-play.yml -e password=${var.controller_password}  > ansible-playbook.log 2> ansible-error.log",
      "echo Controller Configuration Completed"
    ]
  }
}