terraform {
  required_version = ">= 0.13.6"
  required_providers {
    aws = {
      source  = "hashicorp/azurerm"
      version = "~> 2.45.1"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.0.0"
    }
  }
}
#provider "azurerm" {
#  subscription_id = data.azurerm_subscription.primary.id
#}
resource "azurerm_resource_group" "avi" {
  name     = "${var.name_prefix}-avi-resources"
  location = var.region
}