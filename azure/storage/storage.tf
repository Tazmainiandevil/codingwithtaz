# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.0.0"
  features {}
}

variable "resource_group_name" {
  type = string
}
variable "resource_group_location" {
  type = string
}
variable "storage_name" {
  type = string
}
variable "storage_kind" {
  type = string
  default = "StorageV2"
}
variable "storage_sku" {
  type = string
  default = "LRS"
}
variable "storage_tier" {
  type = string
  default = "Standard"
}

# Create a resource group
resource "azurerm_resource_group" "instance" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

# Create the storage account
resource "azurerm_storage_account" "instance" {
  name                     = var.storage_name
  resource_group_name      = azurerm_resource_group.instance.name
  location                 = azurerm_resource_group.instance.location
  account_kind             = var.storage_kind
  account_tier             = var.storage_tier
  account_replication_type = var.storage_sku
}
