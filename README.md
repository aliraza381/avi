# AVI Controller Deployment on GCP Terraform module
This Terraform module creates and configures an AVI (NSX Advanced Load Balancer) Controller on Azure

## Module Functions
The module is meant to be modular and can create all or none of the prerequiste resources needed for the AVI Azure Deployment including:
* VNET and Subnet for the Controller and SEs (optional with create_networking variable)
* Azure Active Directory Roles, and Role Assignment (optional with create_iam variable)
* Network Security Groups for AVI Controller and SE communication
* Azure Virtual Machine Instance using an official AVI Azure Marketplace image
* High Availability AVI Controller Deployment (optional with controller_ha variable)

During the creation of the Controller instance the following initialization steps are performed:
* Copy Ansible playbook to controller using the assigned public IP
* Run Ansible playbook to configure initial settings and Azure Full Access Cloud 


## Usage
This is an example of a controller deployment that leverages an existing VPC (with a cidr_block of 10.154.0.0/16) and 3 subnets. The public key is already created in EC2 and the private key found in the "/home/<user>/.ssh/id_rsa" will be used to copy and run the Ansible playbook to configure the Controller.
```hcl
terraform {
  backend "local" {
  }
}
module "avi-controller-aws" {
  source  = "slarimore02/avi-controller-aws/aws"
  version = "1.0.x"

  region = "us-west-1"
  aws_access_key = "<access-key>"
  aws_secret_key = "<secret-key>"
  create_networking = "false"
  create_iam = "false"
  controller_version = "20.1.3"
  custom_vpc_id = "vpc-<id>"
  custom_subnet_ids = ["subnet-<id>","subnet-<id>","subnet-<id>"]
  avi_cidr_block = "10.154.0.0/16"
  controller_password = "<newpassword>"
  key_pair_name = "<key>"
  private_key_path = "/home/<user>/.ssh/id_rsa"
  name_prefix = "<name>"
  custom_tags = { "Role" : "Avi-Controller", "Owner" : "admin", "Department" : "IT", "shutdown_policy" : "noshut" }
}
output "controller_ip" { 
  value = module.avi_controller_aws.public_address
}
output "ansible_variables" {
  value = module.avi_controller_aws.ansible_variables
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
| [null_resource.ansible_provisioner](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_password.sp](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/password) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_subscription.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/subscription) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avi_cidr_block"></a> [avi\_cidr\_block](#input\_avi\_cidr\_block) | The CIDR that will be used for creating a subnet in the AVI VPC - a /16 should be provided | `string` | `"10.255.0.0/16"` | no |
| <a name="input_avi_version"></a> [avi\_version](#input\_avi\_version) | The AVI Controller version that will be deployed | `string` | n/a | yes |
| <a name="input_controller_default_password"></a> [controller\_default\_password](#input\_controller\_default\_password) | This is the default password for the AVI controller image and can be found in the image download page. | `string` | n/a | yes |
| <a name="input_controller_ha"></a> [controller\_ha](#input\_controller\_ha) | If true a HA controller cluster is deployed and configured | `bool` | `"false"` | no |
| <a name="input_controller_password"></a> [controller\_password](#input\_controller\_password) | The password that will be used authenticating with the AVI Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| <a name="input_controller_public_address"></a> [controller\_public\_address](#input\_controller\_public\_address) | This variable controls if the Controller has a Public IP Address. When set to false the Ansible provisioner will connect to the private IP of the Controller. | `bool` | `"false"` | no |
| <a name="input_controller_vm_size"></a> [controller\_vm\_size](#input\_controller\_vm\_size) | The VM size for the AVI Controller | `string` | `"Standard_D8s_v3"` | no |
| <a name="input_create_iam"></a> [create\_iam](#input\_create\_iam) | Create IAM Service Account, Roles, and Role Bindings for Avi GCP Full Access Cloud | `bool` | `"false"` | no |
| <a name="input_create_networking"></a> [create\_networking](#input\_create\_networking) | This variable controls the VPC and subnet creation for the AVI Controller. When set to false the custom-vpc-name and custom-subnetwork-name must be set. | `bool` | `"true"` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | If true a Resource Group is created and used for the AVI Controllers and Service Engines | `bool` | `"true"` | no |
| <a name="input_custom_controller_resource_group"></a> [custom\_controller\_resource\_group](#input\_custom\_controller\_resource\_group) | This field can be used to specify an existing Resource Group for AVI Controllers. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| <a name="input_custom_se_resource_group"></a> [custom\_se\_resource\_group](#input\_custom\_se\_resource\_group) | This field can be used to specify an existing Resource Group for Service Engines. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| <a name="input_custom_subnet_id"></a> [custom\_subnet\_id](#input\_custom\_subnet\_id) | This field can be used to specify a list of existing VNET Subnet for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| <a name="input_custom_tags"></a> [custom\_tags](#input\_custom\_tags) | Custom tags added to AWS Resources created by the module | `map(string)` | `{}` | no |
| <a name="input_custom_vnet_id"></a> [custom\_vnet\_id](#input\_custom\_vnet\_id) | This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | This prefix is appended to the names of the Controller and SEs | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The Region that the AVI controller and SEs will be deployed to | `string` | n/a | yes |
| <a name="input_root_disk_size"></a> [root\_disk\_size](#input\_root\_disk\_size) | The root disk size for the AVI controller | `number` | `128` | no |
| <a name="input_se_vm_size"></a> [se\_vm\_size](#input\_se\_vm\_size) | The VM size for the AVI Service Engines. This value can be changed in the Service Engine Group configuration after deployment. | `string` | `"Standard_F2s"` | no |
| <a name="input_use_azure_dns"></a> [use\_azure\_dns](#input\_use\_azure\_dns) | If true the AVI Cloud is configured to use Azure DNS | `bool` | `"false"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_controllers"></a> [controllers](#output\_controllers) | The AVI Controller(s) Information |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->