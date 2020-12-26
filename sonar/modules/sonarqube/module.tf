# Generate Random String to Storage Names
resource "random_string" "random" {
  length  = 16
  special = false
  upper   = false
}

# Obtain Container Registry Details
data "azurerm_container_registry" "registry" {
  name                = var.container_registry_config.name
  resource_group_name = var.container_registry_config.resource_group
}

# Storage Account and Shares
resource "azurerm_storage_account" "storage" {
  name                     = lower(substr("${var.storage_config.name}${random_string.random.result}", 0, 24))
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_kind             = var.storage_config.kind
  account_tier             = var.storage_config.tier
  account_replication_type = var.storage_config.sku
  tags                     = var.tags
}

resource "azurerm_storage_share" "data-share" {
  name                 = "data"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = var.storage_share_quota_gb.data
}

resource "azurerm_storage_share" "extensions-share" {
  name                 = "extensions"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = var.storage_share_quota_gb.extensions
}

resource "azurerm_storage_share" "logs-share" {
  name                 = "logs"
  storage_account_name = azurerm_storage_account.storage.name
  quota                = var.storage_share_quota_gb.logs
}


# SQL Server with Firewall
resource "azurerm_sql_server" "sql" {
  name                         = lower("${var.sql_server_config.name}${random_string.random.result}")
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  version                      = var.sql_server_config.version
  administrator_login          = var.sql_server_credentials.admin_username
  administrator_login_password = var.sql_server_credentials.admin_password
  tags                         = var.tags
}

resource "azurerm_sql_firewall_rule" "sqlfirewall" {
  name                = "AllowAllWindowsAzureIps"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "0.0.0.0"
}

# SQL Database
resource "azurerm_mssql_database" "sqldb" {
  name                        = var.sql_database_config.name
  server_id                   = azurerm_sql_server.sql.id
  collation                   = "SQL_Latin1_General_CP1_CS_AS"
  license_type                = "LicenseIncluded"
  max_size_gb                 = var.sql_database_config.max_db_size_gb
  min_capacity                = var.sql_database_config.min_cpu_capacity
  read_scale                  = false
  sku_name                    = "${var.sql_database_config.sku}_${var.sql_database_config.max_cpu_capacity}"
  zone_redundant              = false
  auto_pause_delay_in_minutes = var.sql_database_config.auto_pause_delay_in_minutes
  tags                        = var.tags
}

# Container Group with SonarQube and Caddy
resource "azurerm_container_group" "container" {
  name                = var.sonar_config.container_group_name
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  ip_address_type     = "public"
  dns_name_label      = var.sonar_config.dns_name
  os_type             = "Linux"
  restart_policy      = "OnFailure"
  tags                = var.tags
  
  image_registry_credential {
      server = data.azurerm_container_registry.registry.login_server
      username = data.azurerm_container_registry.registry.admin_username
      password = data.azurerm_container_registry.registry.admin_password
  }

  container {
    name   = "sonarqube-server"
    image  = "${data.azurerm_container_registry.registry.login_server}/${var.sonar_config.image_name}"
    cpu    = var.sonar_config.required_vcpu
    memory = var.sonar_config.required_memory_in_gb
    environment_variables = {
      WEBSITES_CONTAINER_START_TIME_LIMIT = 400
    }    
    secure_environment_variables = {
      SONARQUBE_JDBC_URL      = "jdbc:sqlserver://${azurerm_sql_server.sql.name}.database.windows.net:1433;database=${azurerm_mssql_database.sqldb.name};user=${azurerm_sql_server.sql.administrator_login}@${azurerm_sql_server.sql.name};password=${azurerm_sql_server.sql.administrator_login_password};encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;"
      SONARQUBE_JDBC_USERNAME = var.sql_server_credentials.admin_username
      SONARQUBE_JDBC_PASSWORD = var.sql_server_credentials.admin_password
    }

    ports {
      port     = 9000
      protocol = "TCP"
    }

    volume {
      name                 = "data"
      mount_path           = "/opt/sonarqube/data"
      share_name           = "data"
      storage_account_name = azurerm_storage_account.storage.name
      storage_account_key  = azurerm_storage_account.storage.primary_access_key
    }

    volume {
      name                 = "extensions"
      mount_path           = "/opt/sonarqube/extensions"
      share_name           = "extensions"
      storage_account_name = azurerm_storage_account.storage.name
      storage_account_key  = azurerm_storage_account.storage.primary_access_key
    }

    volume {
      name                 = "logs"
      mount_path           = "/opt/sonarqube/logs"
      share_name           = "logs"
      storage_account_name = azurerm_storage_account.storage.name
      storage_account_key  = azurerm_storage_account.storage.primary_access_key
    }   
  }

  container {
    name     = "caddy-ssl-server"
    image    = "caddy:latest"
    cpu      = "1"
    memory   = "1"
    commands = ["caddy", "reverse-proxy", "--from", "${var.sonar_config.dns_name}.${var.resource_group_location}.azurecontainer.io", "--to", "localhost:9000"]

    ports {
      port     = 443
      protocol = "TCP"
    }

    ports {
      port     = 80
      protocol = "TCP"
    }
  }
}
