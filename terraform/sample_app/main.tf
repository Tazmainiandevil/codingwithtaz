terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.83"
    }
  }
  backend "local" {}
  required_version = ">= 1.0.10"
}

provider "azurerm" {
  features {}
}


module "rgname" {
    source        = "/modules/naming"
    name          = "myapp"
    env           = "rg-${var.env}"
    resource_type = ""
    location      = var.location
    separator     = "-"
}

resource "azurerm_resource_group" "rg" {
  name     = module.rgname.result
  location = "uksouth"
}

module "funcApp" {
  source                    = "/modules/linux_azure_function"
  resource_group            = azurerm_resource_group.rg.name
  resource_group_location   = azurerm_resource_group.rg.location
  env                       = var.env
  appName                   = var.appName
  funcWorkerRuntime         = "dotnet-isolated"
  dotnetVersion             = "v5.0"
  additionalFuncAppSettings = {
    mysetting = "somevalue"
  }
  tags                      = var.tags
}