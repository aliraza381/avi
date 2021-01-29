locals {
  # AKO Settings
  cloud_settings = {
    se_mgmt_subnet_name   = var.create_networking ? azurerm_subnet.avi[0].id : var.custom_subnet_id
    se_vnet_id_path       = var.create_networking ? azurerm_subnet.avi[0].id : var.custom_subnet_id
    region                = var.region
    se_resource_group     = var.create_resource_group ? azurerm_resource_group : var.custom_se_resource_group
    controller_version    = var.controller_version,
    se_name_prefix        = var.name_prefix
    mgmt_security_group   = aws_security_group.avi_se_mgmt_sg.id
    data_security_group   = aws_security_group.avi_data_sg.id
    controller_ha         = var.controller_ha
    controller_name_1     = var.controller_ha ? azurerm_windows_virtual_machine.avi_controller[0].name : null
    controller_ip_1       = var.controller_ha ? azurerm_network_interface.avi[0].private_ip_address: null
    controller_name_2     = var.controller_ha ? azurerm_windows_virtual_machine.avi_controller[1].name : null
    controller_ip_2       = var.controller_ha ? azurerm_network_interface.avi[1].private_ip_address : null
    controller_name_3     = var.controller_ha ? azurerm_windows_virtual_machine.avi_controller[2].name : null
    controller_ip_3       = var.controller_ha ? azurerm_network_interface.avi[2].private_ip_address : null
  }
}
resource "azurerm_windows_virtual_machine" "avi_controller" {
  count = var.controller_ha ? 3 : 1
  name                = "${var.name_prefix}-avi-controller-${count.index + 1}"
  resource_group_name = azurerm_resource_group.avi.name
  location            = azurerm_resource_group.avi.location
  size                = var.instance_type
  network_interface_ids = [
    azurerm_network_interface.avi[count.index].id,
  ]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "avi-networks"
    offer     = "avi-vantage-adc"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

resource "null_resource" "ansible_provisioner" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    controller_instance_ids = join(",", azurerm_windows_virtual_machine.avi_controller.*.id)
  }

  connection {
    type        = "ssh"
    host        = azurerm_windows_virtual_machine.avi_controller[0].public_ip
    user        = "admin"
    timeout     = "600s"
    private_key = file(var.private_key_path)
  }

  provisioner "file" {
    content = templatefile("${path.module}/files/avi-controller-aws-all-in-one-play.yml.tpl",
    local.cloud_settings)
    destination = "/home/admin/avi-controller-aws-all-in-one-play.yml"
  }
  provisioner "remote-exec" {
    inline = [
      "sleep 180",
      "sudo /opt/avi/scripts/initialize_admin_user.py --password ${var.controller_password}",
      "ansible-playbook avi-controller-aws-all-in-one-play.yml -e password=${var.controller_password} -e aws_access_key_id=${var.aws_access_key} -e aws_secret_access_key=${var.aws_secret_key} > ansible-playbook.log 2> ansible-error.log",
      "echo Controller Configuration Completed"
    ]
  }
}