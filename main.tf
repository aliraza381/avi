terraform {
  required_version = ">= 0.13.6"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.1.0"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.20.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.1.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.2"
    }
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}
resource "azurerm_resource_group" "avi" {
  count    = var.create_resource_group ? 1 : 0
  name     = "rg-${var.name_prefix}-avi-${local.region}"
  location = var.region
}