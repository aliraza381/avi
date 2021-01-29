resource "azurerm_role_definition" "avi" {
  count              = var.create_iam ? 1 : 0
  name        = "${var.name_prefix}_Avi_Role"
  scope       = var.subscription_id
  description = "Custom Role for Avi Controller."

  permissions {
    actions     = [ "Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/read",
                    "Microsoft.MarketplaceOrdering/offerTypes/publishers/offers/plans/agreements/write",
                    "Microsoft.Network/virtualNetworks/read",
                    "Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read",
                    "Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read",
                    "Microsoft.Network/virtualNetworks/subnets/read",
                    "Microsoft.Network/virtualNetworks/subnets/join/action",
                    "Microsoft.Network/virtualNetworks/subnets/virtualMachines/read",
                    "Microsoft.Network/virtualNetworks/virtualMachines/read",
                    "Microsoft.Network/networkInterfaces/join/action",
                    "Microsoft.Network/networkInterfaces/read",
                    "Microsoft.Network/networkInterfaces/ipconfigurations/read",
                    "Microsoft.Network/dnsZones/read",
                    "Microsoft.Network/dnsZones/A/*",
                    "Microsoft.Network/dnsZones/CNAME/*",
                    "Microsoft.Compute/virtualMachines/read",
                    "Microsoft.Compute/virtualMachines/instanceView/read",
                    "Microsoft.Compute/virtualMachineScaleSets/read",
                    "microsoft.Compute/virtualMachineScaleSets/*/read",
                    "Microsoft.Resources/resources/read",
                    "Microsoft.Resources/subscriptions/resourcegroups/read",
                    "Microsoft.Resources/subscriptions/resourcegroups/resources/read",
                    "Microsoft.Compute/virtualMachineScaleSets/read",
                    "microsoft.Compute/virtualMachineScaleSets/*/read",
                    "Microsoft.Compute/virtualMachineScaleSets/write",
                    "microsoft.Compute/virtualMachineScaleSets/delete/action"
                  ]
    not_actions = []
  }

  assignable_scopes = [
    "/subscriptions/${var.subscription_id}/resourceGroups/${azurerm_resource_group.avi.name}"
  ]
}
resource "azurerm_role_assignment" "avi" {
  for_each           = toset(azurerm_virtual_machine.avi_controller)
  name               = each.name
  scope              = data.azurerm_subscription.primary.id
  role_definition_id = "${data.azurerm_subscription.subscription.id}${azurerm_role_definition.avi.id}"
  principal_id       = each.identity[0]["principal_id"]
}