output "controllers" {
  description = "The AVI Controller(s) Information"
  value = ([for s in azurerm_linux_virtual_machine.avi_controller : merge(
    { "name" = s.name },
    { "private_ip_address" = s.private_ip_address },
    var.controller_public_address ? { "public_ip_address" = s.public_ip_address } : {}
    )
    ]
  )
}