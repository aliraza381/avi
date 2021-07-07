variable "region" {
  description = "The Region that the AVI controller and SEs will be deployed to"
  type        = string
}
variable "create_resource_group" {
  description = "If true a Resource Group is created and used for the AVI Controllers and Service Engines"
  type        = bool
  default     = "true"
}
variable "use_standard_alb" {
  description = "If true the AVI Cloud is configured to use standard SKU for the Azure LBs"
  type        = bool
  default     = "false"
}
variable "use_azure_dns" {
  description = "If true the AVI Cloud is configured to use Azure DNS"
  type        = bool
  default     = "false"
}
variable "custom_se_resource_group" {
  description = "This field can be used to specify an existing Resource Group for Service Engines. The create_resource_group variable must also be set to false for this resource group to be used."
  type        = string
  default     = ""
}
variable "custom_controller_resource_group" {
  description = "This field can be used to specify an existing Resource Group for AVI Controllers. The create_resource_group variable must also be set to false for this resource group to be used."
  type        = string
  default     = ""
}
variable "name_prefix" {
  description = "This prefix is appended to the names of the Controller and SEs"
  type        = string
}
variable "controller_ha" {
  description = "If true a HA controller cluster is deployed and configured"
  type        = bool
  default     = "false"
}
variable "create_networking" {
  description = "This variable controls the VNET and subnet creation for the AVI Controller. When set to false the custome_network_resource_group, custom_vnet_name and custom_subnet_name variables must be configured."
  type        = bool
  default     = "true"
}
variable "create_vnet_peering" {
  description = "This variable is used to peer the created VNET. If true the vnet_peering_settings variable must be configured"
  type        = bool
  default     = "false"
}
variable "vnet_peering_settings" {
  description = "This variable is used to peer the created VNET. If true the vnet_peering_settings variable must be configured"
  type        = object({ resource_group = string, vnet_name = string, global_peering = bool })
}
variable "controller_public_address" {
  description = "This variable controls if the Controller has a Public IP Address. When set to false the Ansible provisioner will connect to the private IP of the Controller."
  type        = bool
  default     = "false"
}
variable "vnet_address_space" {
  description = "The CIDR that will be used for creating a VNET for Avi resources"
  type        = string
  default     = "10.255.0.0/16"
}
variable "avi_subnet" {
  description = "The CIDR that will be used for creating a subnet in the Avi VNET"
  type        = string
  default     = "10.255.0.0/24"
}
variable "cluster_ip" {
  description = "The IP Address that will be used for the Avi Cluster address. This IP should be in the same subnet as the avi_subnet variable or the subnet specified with the custom_subnet_name"
  type        = string
  default     = "10.255.0.250"
}
variable "custom_network_resource_group" {
  description = "This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used."
  type        = string
  default     = ""
}
variable "custom_vnet_name" {
  description = "This field can be used to specify an existing VNET for the controller and SEs. The create-networking variable must also be set to false for this network to be used."
  type        = string
  default     = ""
}
variable "custom_subnet_name" {
  description = "This field can be used to specify a list of existing VNET Subnet for the controller and SEs. The create-networking variable must also be set to false for this network to be used."
  type        = string
  default     = ""
}
variable "create_iam" {
  description = "Create Azure AD Application and Service Principal, Controller Custom Role, and Application Role Binding for Avi Azure Full Access Cloud"
  type        = bool
  default     = "false"
}
variable "controller_default_password" {
  description = "This is the default password for the AVI controller image and can be found in the image download page."
  type        = string
  sensitive   = false
}
variable "controller_password" {
  description = "The password that will be used authenticating with the AVI Controller. This password be a minimum of 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters"
  type        = string
  sensitive   = false
  validation {
    condition     = length(var.controller_password) > 7
    error_message = "The controller_password value must be more than 8 characters and contain at least one each of uppercase, lowercase, numbers, and special characters."
  }
}
variable "controller_vm_size" {
  description = "The VM size for the AVI Controller"
  type        = string
  default     = "Standard_D8s_v3"
}
variable "se_vm_size" {
  description = "The VM size for the AVI Service Engines. This value can be changed in the Service Engine Group configuration after deployment."
  type        = string
  default     = "Standard_F2s"
}
variable "root_disk_size" {
  description = "The root disk size for the AVI controller"
  type        = number
  default     = 128
  validation {
    condition     = var.root_disk_size >= 128
    error_message = "The Controller root disk size should be greater than or equal to 128 GB."
  }
}
variable "custom_tags" {
  description = "Custom tags added to Resources created by the module"
  type        = map(string)
  default     = {}
}
variable "configure_dns_profile" {
  description = "Configure Avi DNS Profile for DNS Record Creation for Virtual Services. If set to true the dns_service_domain variable must also be set"
  type        = bool
  default     = "false"
}
variable "dns_service_domain" {
  description = "The DNS Domain that will be available for Virtual Services. Avi will be the Authorative Nameserver for this domain and NS records may need to be created pointing to the Avi Service Engine addresses. An example is demo.Avi.com"
  type        = string
  default     = ""
}
variable "configure_dns_vs" {
  description = "Create DNS Virtual Service. The configure_dns_profile and configure_ipam_profile variables must be set to true and their associated configuration variables must also be set"
  type        = bool
  default     = "false"
}
variable "dns_vs_settings" {
  description = "The DNS Virtual Service settings. With the auto_allocate_ip option is set to \"true\" the VS IP address will be allocated via an IPAM profile. Example:{ auto_allocate_ip = \"true\", auto_allocate_public_ip = \"true\", vs_ip = \"\", network_name = \"network-192.168.20.0/24\", network = \"192.168.20.0/24\" }"
  type        = object({ subnet_name = string, allocate_public_ip = bool })
  default     = null
}
variable "configure_gslb" {
  description = "Configure GSLB. The gslb_site_name, gslb_domains, and configure_dns_vs variables must also be set. Optionally the additional_gslb_sites variable can be used to add active GSLB sites"
  type        = bool
  default     = "false"
}
variable "gslb_site_name" {
  description = "The name of the GSLB site the deployed Controller(s) will be a member of."
  type        = string
  default     = ""
}
variable "gslb_domains" {
  description = "A list of GSLB domains that will be configured"
  type        = list(string)
  default     = [""]
}
variable "configure_gslb_additional_sites" {
  description = "Configure Additional GSLB Sites. The additional_gslb_sites, gslb_site_name, gslb_domains, and configure_dns_vs variables must also be set. Optionally the additional_gslb_sites variable can be used to add active GSLB sites"
  type        = bool
  default     = "false"
}
variable "additional_gslb_sites" {
  description = "The Names and IP addresses of the GSLB Sites that will be configured. If the Site is a controller cluster the ip_address_list should have the ip address of each controller."
  type        = list(object({ name = string, ip_address_list = list(string), dns_vs_name = string }))
  default     = [{ name = "", ip_address_list = [""], dns_vs_name = "DNS-VS" }]
}
variable "se_ha_mode" {
  description = "The HA mode of the Service Engine Group. Possible values active/active, n+m, or active/standby"
  type        = string
  default     = "active/active"
  validation {
    condition     = contains(["active/active", "n+m", "active/standby"], var.se_ha_mode)
    error_message = "Acceptable values are active/active, n+m, or active/standby."
  }
}
variable "dns_servers" {
  description = "The optional DNS servers that will be used for local DNS resolution by the controller. Example [\"8.8.4.4\", \"8.8.8.8\"]"
  type        = list(string)
  default     = null
}
variable "dns_search_domain" {
  description = "The optional DNS search domain that will be used by the controller"
  type        = string
  default     = null
}
variable "ntp_servers" {
  description = "The NTP Servers that the Avi Controllers will use. The server should be a valid IP address (v4 or v6) or a DNS name. Valid options for type are V4, DNS, or V6"
  type        = list(object({ addr = string, type = string }))
  default     = [{ addr = "0.us.pool.ntp.org", type = "DNS" }, { addr = "1.us.pool.ntp.org", type = "DNS" }, { addr = "2.us.pool.ntp.org", type = "DNS" }, { addr = "3.us.pool.ntp.org", type = "DNS" }]
}
variable "email_config" {
  description = "The Email settings that will be used for sending password reset information or for trigged alerts. The default setting will send emails directly from the Avi Controller"
  sensitive   = true
  type        = object({ smtp_type = string, from_email = string, mail_server_name = string, mail_server_port = string, auth_username = string, auth_password = string })
  default     = { smtp_type = "SMTP_LOCAL_HOST", from_email = "admin@avicontroller.net", mail_server_name = "localhost", mail_server_port = "25", auth_username = "", auth_password = "" }
}