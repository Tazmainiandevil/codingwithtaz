terraform {  
  required_version = ">= 0.14"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.37.0"
    }
  }
}

provider "azurerm" {  
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "instance" {
  name     = "test-sonar"
  location = "uksouth"
}

# Generate Password
resource "random_password" "password" {
  length = 24
  special = true
  override_special = "_%@"
}

# Module
module "sonarqube" {
    depends_on                        = [azurerm_resource_group.instance]
    source                            = "./modules/sonarqube"
    tags                              = { Project = "Sonar", Environment = "Dev" }
    resource_group_name               = azurerm_resource_group.instance.name
    resource_group_location           = azurerm_resource_group.instance.location
    
    sql_server_credentials            = {
        admin_username = "sonaradmin"
        admin_password = random_password.password.result
    }

    container_registry_config         = {
        name           = "myregistry"
        resource_group = "my-registry-rg"
    }

    sonar_config                      = {
        container_group_name  = "sonarqubecontainer"
        required_memory_in_gb = "4"
        required_vcpu         = "2"
        image_name            = "my-sonar:latest"
        dns_name              = "my-custom-sonar"
    }

    sql_server_config                = {
       name    = "sql-sonarqube"
       version = "12.0"
    }

    sql_database_config              = {
        name                        = "sonarqubedb"
        sku                         = "GP_S_Gen5"
        auto_pause_delay_in_minutes = 60
        min_cpu_capacity            = 0.5
        max_cpu_capacity            = 2
        max_db_size_gb              = 250
    }

    storage_share_quota_gb            = {  
        data       = 50
        extensions = 10
        logs       = 20
    }
}
