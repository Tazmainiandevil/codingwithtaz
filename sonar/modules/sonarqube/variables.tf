variable "resource_group_name" {
  type = string
  description = "(Required) Resource Group to deploy to"
}

variable "resource_group_location" {
  type = string
  description = "(Required) Resource Group location"
}

variable "tags" {
  description = "(Required) Tags for SonarQube"
}

variable "container_registry_config" {
    type = object({
        name           = string
        resource_group = string
    })
    description = "(Required) Container Registry Configuration"
}

variable "sonar_config" {
    type = object({
        image_name            = string
        container_group_name  = string
        dns_name              = string
        required_memory_in_gb = string
        required_vcpu         = string
    })

    description = "(Required) SonarQube Configuration"
}

variable "sql_server_credentials" {
    type = object({
        admin_username = string
        admin_password = string
    })
    sensitive = true
}

variable "sql_database_config" {
    type = object({
        name                        = string
        sku                         = string
        auto_pause_delay_in_minutes = number
        min_cpu_capacity            = number
        max_cpu_capacity            = number
        max_db_size_gb              = number
    })
    default = {
        name                        = "sonarqubedb"
        sku                         = "GP_S_Gen5"
        auto_pause_delay_in_minutes = 60
        min_cpu_capacity            = 0.5
        max_cpu_capacity            = 1
        max_db_size_gb              = 50
    }
}

variable "sql_server_config" {
   type = object({
        name    = string
        version = string
   })
   default = {
       name    = "sql-sonarqube"
       version = "12.0"
   }
}

variable "storage_share_quota_gb" {
  type = object({
    data       = number
    extensions = number
    logs       = number
  })
  default = {
      data       = 10
      extensions = 10
      logs       = 10
  }
}

variable "storage_config" {
    type = object({
        name = string
        kind = string
        sku  = string        
        tier = string
    })
    default = {
        name = "sonarqubestore"
        kind = "StorageV2"
        sku  = "LRS"
        tier = "Standard"
    }
}