# Configure the Azure provider
terraform {

  backend "azurerm" {
    resource_group_name  = "mediawiki-devops-rg"
    storage_account_name = "mediawikidevopsst"
    container_name       = "tfstate"
    key                  = "test.tfstate"
  }

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  tenant_id       = var.tenant_id
  subscription_id = var.subscription_id
  features {}
}

