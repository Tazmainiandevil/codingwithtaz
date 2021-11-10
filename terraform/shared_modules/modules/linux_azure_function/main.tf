
module "appInsightsName" {
    source = "/modules/naming"
    name = var.appName
    env = "dev"
    resource_type = "appi"
    location = var.resource_group_location
    separator = "-"
}

module "appPlanName" {
    source = "/modules/naming"
    name = var.appName
    env = "dev"
    resource_type = "plan"
    location = var.resource_group_location
    separator = "-"
}

module "funcName" {
    source = "/modules/naming"
    name = var.appName
    env = "dev"
    resource_type = "func"
    location = var.resource_group_location
    separator = "-"
}

module "storageName" {
    source = "/modules/naming"
    name = var.appName
    env = "dev"
    resource_type = "st"
    location = var.resource_group_location
    separator = ""
}

resource "azurerm_application_insights" "instance" {
  name                = module.appInsightsName.result
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  application_type    = var.appInsightsType
  tags                = var.tags
}

resource "azurerm_app_service_plan" "instance" {
  name                = module.appPlanName.result
  resource_group_name = var.resource_group
  location            = var.resource_group_location
  kind                = "FunctionApp"
  reserved            = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
  tags                = var.tags
}

resource "azurerm_storage_account" "instance" {
  name                     = module.storageName.result
  resource_group_name      = var.resource_group
  location                 = var.resource_group_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = var.tags
}

resource "azurerm_function_app" "instance" {
  name                       = module.funcName.result
  resource_group_name        = var.resource_group
  location                   = var.resource_group_location
  app_service_plan_id        = azurerm_app_service_plan.instance.id
  storage_account_name       = azurerm_storage_account.instance.name
  storage_account_access_key = azurerm_storage_account.instance.primary_access_key
  https_only                 = true
  os_type                    = "linux"
  version                    = var.funcVersion
  tags                       = var.tags
  app_settings = merge({
    FUNCTIONS_WORKER_RUNTIME       = var.funcWorkerRuntime,
    AzureWebJobsStorage            = azurerm_storage_account.instance.primary_connection_string,
    APPINSIGHTS_INSTRUMENTATIONKEY = azurerm_application_insights.instance.instrumentation_key,
    WEBSITE_RUN_FROM_PACKAGE       = "1"
  }, var.additionalFuncAppSettings)

  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state                = "Disabled"
    http2_enabled             = true
    min_tls_version           = "1.2"
    use_32_bit_worker_process = false
    dotnet_framework_version  = var.dotnetVersion
  }

  depends_on = [
      azurerm_application_insights.instance,
      azurerm_storage_account.instance,
      azurerm_app_service_plan.instance
  ]
}