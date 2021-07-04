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
#output "public_address" {
#  description = "Public IP Addresses for the AVI Controller(s)"
#  value       = [for s in aws_instance.avi_controller : s.public_ip]
#}
#output "ansible_variables" {
#  description = "The Ansible variables used to configure the AVI Controller"
#  value       = local.cloud_settings
#}