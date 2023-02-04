terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.42.0"
    }
  }
}
# Configure the Azure Provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "instance" {
  name     = "my-frontdoor-rg"
  location = "westeurope"
}

# Create Front Door
module "front-door" {
  source                                     = "./modules/frontdoor"
  tags                                       = { Department = "Ops" }
  frontdoor_resource_group_name              = azurerm_resource_group.instance.name
  frontdoor_name                             = "mj-frontdoor"
  frontdoor_loadbalancer_enabled             = true
  backend_pools_send_receive_timeout_seconds = 240

  frontend_endpoints = [{
    name                              = "mj-frontdoor-frontend-endpoint"
    host_name                         = "mj-frontdoor.azurefd.net"
    custom_https_provisioning_enabled = false
    custom_https_configuration = [{
      certificate_source         = "FrontDoor"
    }]
    session_affinity_enabled     = false
    session_affinity_ttl_seconds = 0
    waf_policy_link_id           = ""
  }]

  frontdoor_routing_rule = [{
    name               = "my-routing-rule"
    accepted_protocols = ["Http", "Https"]
    patterns_to_match  = ["/*"]
    enabled            = true
    configuration      = "Forwarding"
    forwarding_configuration = [{
      backend_pool_name                     = "backendBing"
      cache_enabled                         = false
      cache_use_dynamic_compression         = false
      cache_query_parameter_strip_directive = "StripNone"
      custom_forwarding_path                = ""
      forwarding_protocol                   = "MatchRequest"
    }]
  }]

  frontdoor_loadbalancer = [{
    name                            = "loadbalancer"
    sample_size                     = 4
    successful_samples_required     = 2
    additional_latency_milliseconds = 0
  }]

  frontdoor_health_probe = [{
    name                = "healthprobe"
    enabled             = true
    path                = "/"
    protocol            = "Http"
    probe_method        = "HEAD"
    interval_in_seconds = 60
  }]

  frontdoor_backend = [{
    name               = "backendBing"
    loadbalancing_name = "loadbalancer"
    health_probe_name  = "healthprobe"
    backend = [{
      enabled     = true
      host_header = "www.bing.com"
      address     = "www.bing.com"
      http_port   = 80
      https_port  = 443
      priority    = 1
      weight      = 50
    }]
  }]
}
