# Configure the Azure provider
terraform {

  backend "azurerm" {}

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  #tenant_id       = var.tenant_id
  #subscription_id = var.subscription_id
  features {}
}