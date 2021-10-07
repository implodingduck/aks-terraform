terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  cluster_name = "aksterra${random_string.unique.result}"
  loc_for_naming = lower(replace(var.location, " ", ""))
  tags = {
    "managed_by" = "terraform"
    "repo"       = "aks-terraform"
  }
}

data "azurerm_client_config" "current" {}


resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_resource_group" "aks" {
  name     = "rg-aks-${var.cluster_name}-${local.loc_for_naming}"
  location = var.location
}


resource "azurerm_virtual_network" "default" {
  name                = "${var.cluster_name}-vnet-${local.loc_for_naming}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  address_space       = ["10.0.0.0/16"]

  tags = local.tags
}

resource "azurerm_subnet" "default" {
  name                 = "default-subnet-${local.loc_for_naming}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "cluster" {
  name                 = "${var.cluster_name}-subnet-${local.loc_for_naming}"
  resource_group_name  = azurerm_resource_group.aks.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.0.2.0/23"]

}

resource "azurerm_kubernetes_cluster" "example" {
  name                = var.cluster_name
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = replace(replace(replace(var.cluster_name, "-", ""), "_", ""), " ", "")
  kubernetes_version  = "1.21.2"
  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_D2_v2"
    os_disk_size_gb = "128"
    vnet_subnet_id  = azurerm_subnet.cluster.id


  }
  network_profile {
    network_plugin     = "azure"
    network_policy     = "azure"
    service_cidr       = "10.255.252.0/22"
    dns_service_ip     = "10.255.252.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = local.tags
}

