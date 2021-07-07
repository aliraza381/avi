# AVI Controller Deployment on Azure Terraform module
This Terraform module creates and configures an AVI (NSX Advanced Load Balancer) Controller on Azure

## Module Functions
The module is meant to be modular and can create all or none of the prerequiste resources needed for the AVI Azure Deployment including:
* VNET and Subnet for the Controller and SEs (configured with create_networking variable)
* VNET Peering (configured with create_vnet_peering and vnet_peering_settings variables)
* Azure Active Directory Application, Service Principal, Custom Role, and Role Assignment for the Controller (configured with create_iam variable)
* Network Security Groups for AVI Controller and SE communication (future work)
* Azure Virtual Machine Instance using an official AVI Azure Marketplace image
* High Availability AVI Controller Deployment (configured with controller_ha variable)

During the creation of the Controller instance the following initialization steps are performed:
* Copy Ansible playbook to controller using the assigned public IP
* Run Ansible playbook to configure initial settings and Azure Full Access Cloud

The Ansible playbook can optionally add these configurations:
* Create Avi DNS Profile (configured with configure_dns_profile and dns_service_domain variables)
* Create Avi DNS Virtual Service (configured with configure_dns_vs and dns_vs_settings variables)
* Configure GSLB (configured with configure_gslb, gslb_site_name, gslb_domains, and configure_gslb_additional_sites variables)


## Usage
This is an example of an HA controller deployment that creates the controller and all other requisite Azure resources. A Cluster IP is utilized for the deployment and configured with the cluster_ip variable. 
```hcl
terraform {
  backend "local" {
  }
}
module "avi_controller_azure" {
  source  = "slarimore02/avi-controller-azure/azurerm"
  version = "1.0.x"

  region                       = "westus2"
  name_prefix                  = "slarimore"
  controller_default_password  = "Value Redacted and available within the VMware Customer Portal"
  controller_password          = "<newpassword>"
  create_networking            = true
  create_iam                   = true
  controller_ha                = true
  controller_public_address    = true
  custom_tags                  = { "Role" : "Avi-Controller", "Owner" : "user@email.com", "Department" : "IT" }
  se_ha_mode                   = "active/active"
  vnet_address_space           = "10.255.0.0/16"
  avi_subnet                   = "10.255.0.0/24"
  cluster_ip                   = "10.255.0.250"
}
output "controller_info" { 
  value = module.avi_controller_azure.controllers
}
```
## GSLB Deployment Example
The example below shows a GSLB deployment with 2 regions utilized. VNET Peering is configured (with create_vnet_peering and vnet_peering_settings variables) between the two newly created Avi VNETs so that the controllers can communicate. In addition a Cluster IP is specified with the cluster_ip variable. 
```hcl
terraform {
  backend "local" {
  }
}
module "avi_controller_azure_westus2" {
  source  = "slarimore02/avi-controller-azure/azurerm"
  version = "1.0.x"

  region                       = "westus2"
  name_prefix                  = "companyname"
  controller_default_password  = "Value Redacted and available within the VMware Customer Portal"
  controller_password          = "<newpassword>"
  create_networking            = true
  create_vnet_peering             = true
  vnet_peering_settings           = { global_peering = true, resource_group = "rg-<name_prefix>-avi-<region>", vnet_name      = "<name_prefix>-avi-vnet-<region>" }
  create_iam                   = true
  controller_ha                = true
  controller_public_address    = true
  custom_tags                  = { "Role" : "Avi-Controller", "Owner" : "user@email.com", "Department" : "IT" }
  se_ha_mode                   = "active/active"
  vnet_address_space           = "10.251.0.0/16"
  avi_subnet                   = "10.251.0.0/24"
  cluster_ip                   = "10.251.0.250"
  configure_dns_profile        = "true"
  dns_service_domain           = "west2.avidemo.net"
  configure_dns_vs             = "true"
  dns_vs_settings              = { allocate_public_ip = "true", subnet_name = "companyname-avi-subnet" }
}
module "avi_controller_azure_eastus2" {
  source  = "slarimore02/avi-controller-azure/azurerm"
  version = "1.0.x"

  region                          = "eastus2"
  name_prefix                     = "companyname"
  controller_default_password     = "Value Redacted and available within the VMware Customer Portal"
  controller_password             = "<newpassword>"
  create_networking               = true
  create_vnet_peering             = true
  vnet_peering_settings           = { global_peering = true, resource_group = "rg-<name_prefix>-avi-<region>", vnet_name      = "<name_prefix>-avi-vnet-<region>" }
  create_iam                      = true
  controller_ha                   = true
  controller_public_address       = true
  custom_tags                     = { "Role" : "Avi-Controller", "Owner" : "user@email.com", "Department" : "IT" }
  se_ha_mode                      = "active/active"
  vnet_address_space              = "10.252.0.0/16"
  avi_subnet                      = "10.252.0.0/24"
  cluster_ip                      = "10.252.0.250"
  configure_dns_profile           = "true"
  dns_service_domain              = "east2.avidemo.net"
  configure_dns_vs                = "true"
  dns_vs_settings                 = { allocate_public_ip = "true", subnet_name = "companyname-avi-subnet" }
  configure_gslb                  = "true"
  gslb_site_name                  = "East2"
  gslb_domains                    = ["gslb.avidemo.net"]
  configure_gslb_additional_sites = "true"
  additional_gslb_sites           = [{name = "West2", ip_address = 10.251.0.250 , dns_vs_name = "DNS-VS"}]
}
output "controller_info" { 
  value = module.avi_controller_azure.controllers
}
```
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.13.6 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 1.6.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 2.66.0 |
| <a name="requirement_null"></a> [null](#requirement\_null) | ~> 3.1.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | ~> 3.1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 1.6.0 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 2.66.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.1.0 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.1.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azuread_application.avi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application) | resource |
| [azuread_application_password.avi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_password) | resource |
| [azuread_service_principal.avi](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/service_principal) | resource |
| [azurerm_linux_virtual_machine.avi_controller](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine) | resource |
| [azurerm_marketplace_agreement.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement) | resource |
| [azurerm_network_interface.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_public_ip.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.custom_controller](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_definition.custom_controller](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_definition) | resource |
| [azurerm_subnet.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_virtual_network.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |
| [azurerm_virtual_network_peering.avi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_peering) | resource |
| [null_resource.ansible_provisioner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.sp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subnet.custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subnet) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |
| [azurerm_virtual_network.peer](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/virtual_network) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_gslb_sites"></a> [additional\_gslb\_sites](#input\_additional\_gslb\_sites) | The Names and IP addresses of the GSLB Sites that will be configured. | `list(object({ name = string, ip_address = string, dns_vs_name = string }))` | <pre>[<br>  {<br>    "dns_vs_name": "",<br>    "ip_address": "",<br>    "name": ""<br>  }<br>]</pre> | no |
| <a name="input_avi_subnet"></a> [avi\_subnet](#input\_avi\_subnet) | The CIDR that will be used for creating a subnet in the Avi VNET | `string` | `"10.255.0.0/24"` | no |
| <a name="input_avi_version"></a> [avi\_version](#input\_avi\_version) | The version of Avi that will be deployed | `string` | n/a | yes |
| <a name="input_cluster_ip"></a> [cluster\_ip](#input\_cluster\_ip) | The IP Address that will be used for the Avi Cluster address. This IP should be in the same subnet as the avi\_subnet variable or the subnet specified with the custom\_subnet\_name | `string` | `"10.255.0.250"` | no |
| <a name="input_configure_dns_profile"></a> [configure\_dns\_profile](#input\_configure\_dns\_profile) | Configure Avi DNS Profile for DNS Record Creation for Virtual Services. If set to true the dns\_service\_domain variable must also be set | `bool` | `"false"` | no |
| <a name="input_configure_dns_vs"></a> [configure\_dns\_vs](#input\_configure\_dns\_vs) | Create DNS Virtual Service. The configure\_dns\_profile and configure\_ipam\_profile variables must be set to true and their associated configuration variables must also be set | `bool` | `"false"` | no |
| <a name="input_configure_gslb"></a> [configure\_gslb](#input\_configure\_gslb) | Configure GSLB. The gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| <a name="input_configure_gslb_additional_sites"></a> [configure\_gslb\_additional\_sites](#input\_configure\_gslb\_additional\_sites) | Configure Additional GSLB Sites. The additional\_gslb\_sites, gslb\_site\_name, gslb\_domains, and configure\_dns\_vs variables must also be set. Optionally the additional\_gslb\_sites variable can be used to add active GSLB sites | `bool` | `"false"` | no |
| <a name="input_controller_default_password"></a> [controller\_default\_password](#input\_controller\_default\_password) | This is the default password for the AVI controller image and can be found in the image download page. | `string` | n/a | yes |
| <a name="input_controller_ha"></a> [controller\_ha](#input\_controller\_ha) | If true a HA controller cluster is deployed and configured | `bool` | `"false"` | no |
| <a name="input_controller_password"></a> [controller\_password](#input\_controller\_password) | The password that will be used authenticating with the AVI Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| <a name="input_controller_public_address"></a> [controller\_public\_address](#input\_controller\_public\_address) | This variable controls if the Controller has a Public IP Address. When set to false the Ansible provisioner will connect to the private IP of the Controller. | `bool` | `"false"` | no |
| <a name="input_controller_vm_size"></a> [controller\_vm\_size](#input\_controller\_vm\_size) | The VM size for the AVI Controller | `string` | `"Standard_D8s_v3"` | no |
| <a name="input_create_iam"></a> [create\_iam](#input\_create\_iam) | Create Azure AD Application and Service Principal, Controller Custom Role, and Application Role Binding for Avi Azure Full Access Cloud | `bool` | `"false"` | no |
| <a name="input_create_networking"></a> [create\_networking](#input\_create\_networking) | This variable controls the VNET and subnet creation for the AVI Controller. When set to false the custome\_network\_resource\_group, custom\_vnet\_name and custom\_subnet\_name variables must be configured. | `bool` | `"true"` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | If true a Resource Group is created and used for the AVI Controllers and Service Engines | `bool` | `"true"` | no |
| <a name="input_create_vnet_peering"></a> [create\_vnet\_peering](#input\_create\_vnet\_peering) | This variable is used to peer the created VNET. If true the vnet\_peering\_settings variable must be configured | `bool` | `"false"` | no |
| <a name="input_custom_controller_resource_group"></a> [custom\_controller\_resource\_group](#input\_custom\_controller\_resource\_group) | This field can be used to specify an existing Resource Group for AVI Controllers. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| <a name="input_custom_network_resource_group"></a> [custom\_network\_resource\_group](#input\_custom\_network\_resource\_group) | This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| <a name="input_custom_se_resource_group"></a> [custom\_se\_resource\_group](#input\_custom\_se\_resource\_group) | This field can be used to specify an existing Resource Group for Service Engines. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| <a name="input_custom_subnet_name"></a> [custom\_subnet\_name](#input\_custom\_subnet\_name) | This field can be used to specify a list of existing VNET Subnet for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Custom tags added to Resources created by the module | `map(string)` | `{}` | no |
| <a name="input_custom_vnet_name"></a> [custom\_vnet\_name](#input\_custom\_vnet\_name) | This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| <a name="input_dns_search_domain"></a> [dns\_search\_domain](#input\_dns\_search\_domain) | The optional DNS search domain that will be used by the controller | `string` | `null` | no |
| <a name="input_dns_servers"></a> [dns\_servers](#input\_dns\_servers) | The optional DNS servers that will be used for local DNS resolution by the controller. Example ["8.8.4.4", "8.8.8.8"] | `list(string)` | `null` | no |
| <a name="input_dns_service_domain"></a> [dns\_service\_domain](#input\_dns\_service\_domain) | The DNS Domain that will be available for Virtual Services. Avi will be the Authorative Nameserver for this domain and NS records may need to be created pointing to the Avi Service Engine addresses. An example is demo.Avi.com | `string` | `""` | no |
| <a name="input_dns_vs_settings"></a> [dns\_vs\_settings](#input\_dns\_vs\_settings) | The DNS Virtual Service settings. With the auto\_allocate\_ip option is set to "true" the VS IP address will be allocated via an IPAM profile. Example:{ auto\_allocate\_ip = "true", auto\_allocate\_public\_ip = "true", vs\_ip = "", network\_name = "network-192.168.20.0/24", network = "192.168.20.0/24" } | `object({ subnet_name = string, allocate_public_ip = bool })` | `null` | no |
| <a name="input_email_config"></a> [email\_config](#input\_email\_config) | The Email settings that will be used for sending password reset information or for trigged alerts. The default setting will send emails directly from the Avi Controller | `object({ smtp_type = string, from_email = string, mail_server_name = string, mail_server_port = string, auth_username = string, auth_password = string })` | <pre>{<br>  "auth_password": "",<br>  "auth_username": "",<br>  "from_email": "admin@avicontroller.net",<br>  "mail_server_name": "localhost",<br>  "mail_server_port": "25",<br>  "smtp_type": "SMTP_LOCAL_HOST"<br>}</pre> | no |
| <a name="input_gslb_domains"></a> [gslb\_domains](#input\_gslb\_domains) | A list of GSLB domains that will be configured | `list(string)` | <pre>[<br>  ""<br>]</pre> | no |
| <a name="input_gslb_site_name"></a> [gslb\_site\_name](#input\_gslb\_site\_name) | The name of the GSLB site the deployed Controller(s) will be a member of. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This prefix is appended to the names of the Controller and SEs | `string` | n/a | yes |
| <a name="input_ntp_servers"></a> [ntp\_servers](#input\_ntp\_servers) | The NTP Servers that the Avi Controllers will use. The server should be a valid IP address (v4 or v6) or a DNS name. Valid options for type are V4, DNS, or V6 | `list(object({ addr = string, type = string }))` | <pre>[<br>  {<br>    "addr": "0.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "1.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "2.us.pool.ntp.org",<br>    "type": "DNS"<br>  },<br>  {<br>    "addr": "3.us.pool.ntp.org",<br>    "type": "DNS"<br>  }<br>]</pre> | no |
| <a name="input_region"></a> [region](#input\_region) | The Region that the AVI controller and SEs will be deployed to | `string` | n/a | yes |
| <a name="input_root_disk_size"></a> [root\_disk\_size](#input\_root\_disk\_size) | The root disk size for the AVI controller | `number` | `128` | no |
| <a name="input_se_ha_mode"></a> [se\_ha\_mode](#input\_se\_ha\_mode) | The HA mode of the Service Engine Group. Possible values active/active, n+m, or active/standby | `string` | `"active/active"` | no |
| <a name="input_se_vm_size"></a> [se\_vm\_size](#input\_se\_vm\_size) | The VM size for the AVI Service Engines. This value can be changed in the Service Engine Group configuration after deployment. | `string` | `"Standard_F2s"` | no |
| <a name="input_use_azure_dns"></a> [use\_azure\_dns](#input\_use\_azure\_dns) | If true the AVI Cloud is configured to use Azure DNS | `bool` | `"false"` | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | The CIDR that will be used for creating a VNET for Avi resources | `string` | `"10.255.0.0/16"` | no |
| <a name="input_vnet_peering_settings"></a> [vnet\_peering\_settings](#input\_vnet\_peering\_settings) | This variable is used to peer the created VNET. If true the vnet\_peering\_settings variable must be configured | `object({ resource_group = string, vnet_name = string, global_peering = bool })` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controllers"></a> [controllers](#output\_controllers) | The AVI Controller(s) Information |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->