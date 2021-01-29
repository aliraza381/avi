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
| terraform | >= 0.13.6 |
| azurerm | ~> 2.45.1 |
| null | 3.0.0 |

## Providers

| Name | Version |
|------|---------|
| azurerm | ~> 2.45.1 |
| null | 3.0.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| avi\_cidr\_block | The CIDR that will be used for creating a subnet in the AVI VPC - a /16 should be provided | `string` | `"10.255.0.0/16"` | no |
| controller\_default\_password | This is the default password for the AVI controller image and can be found in the image download page. | `string` | n/a | yes |
| controller\_ha | If true a HA controller cluster is deployed and configured | `bool` | `"false"` | no |
| controller\_password | The password that will be used authenticating with the AVI Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters | `string` | n/a | yes |
| controller\_version | The AVI Controller version that will be deployed | `string` | n/a | yes |
| controller\_vm\_size | The VM size for the AVI Controller | `string` | `"Standard D8s v3"` | no |
| create\_iam | Create IAM Service Account, Roles, and Role Bindings for Avi GCP Full Access Cloud | `bool` | `"false"` | no |
| create\_networking | This variable controls the VPC and subnet creation for the AVI Controller. When set to false the custom-vpc-name and custom-subnetwork-name must be set. | `bool` | `"true"` | no |
| create\_resource\_group | If true a Resource Group is created and used for the AVI Controllers and Service Engines | `bool` | `"true"` | no |
| custom\_controller\_resource\_group | This field can be used to specify an existing Resource Group for AVI Controllers. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| custom\_se\_resource\_group | This field can be used to specify an existing Resource Group for Service Engines. The create\_resource\_group variable must also be set to false for this resource group to be used. | `string` | `""` | no |
| custom\_subnet\_id | This field can be used to specify a list of existing VNET Subnet for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| custom\_tags | Custom tags added to AWS Resources created by the module | `map(string)` | `{}` | no |
| custom\_vnet\_id | This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used. | `string` | `""` | no |
| name\_prefix | This prefix is appended to the names of the Controller and SEs | `string` | n/a | yes |
| region | The Region that the AVI controller and SEs will be deployed to | `string` | n/a | yes |
| root\_disk\_size | The root disk size for the AVI controller | `number` | `128` | no |
| se\_vm\_size | The VM size for the AVI Service Engines. This value can be changed in the Service Engine Group configuration after deployment. | `string` | `"Standard F2s"` | no |
| use\_azure\_dns | If true the AVI Cloud is configured to use Azure DNS | `bool` | `"false"` | no |

## Outputs

No output.

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->