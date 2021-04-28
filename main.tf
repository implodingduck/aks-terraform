terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    azuread = {
      source = "hashicorp/azuread"
      version = "=1.4.0"
    }
  }
  backend "azurerm" {
    resource_group_name   = ""
    storage_account_name  = ""
    container_name        = ""
    key                   = ""
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

provider "azuread" {

}
