terraform {
  required_version = ">= 0.12"
}
# Configure the Azure Provider
provider "azurerm" {
  # whilst the `version` attribute is optional, we recommend pinning to a given version of the Provider
  version = "=2.14.0"
  features {}
}

module "front-door" {
    source                                            = "./modules/frontdoor"    
    tags                                              = { Department = "Ops"}
    frontdoor_resource_group_name                     = "mj-test-fd"
    frontdoor_resource_group_location                 = "westeurope"
    frontdoor_name                                    = "mj-frontdoor"
    frontdoor_loadbalancer_enabled                    = true
    backend_pools_send_receive_timeout_seconds        = 240
    custom_https_provisioning_enabled                 = false
    custom_https_configuration                        = { certificate_source = "FrontDoor"}
    frontdoor_routing_rule = [{
    name               = "exampleRoutingRule1"
    frontend_endpoints = ["mj-frontdoorFrontendEndpoint"]
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
    redirect_configuration = [{
        custom_host         = ""             
        redirect_protocol   = "MatchRequest"   
        redirect_type       = "Found"        
        custom_fragment     = ""
        custom_path         = ""
        custom_query_string = ""
      }]
  }]

  frontdoor_loadbalancer =  [
    {      
      name                            = "loadbalancer"
      sample_size                     = 4
      successful_samples_required     = 2
      additional_latency_milliseconds = 0
    }]

    frontdoor_health_probe = [
    {      
      name                = "healthprobe"
      enabled             = true
      path                = "/"
      protocol            = "Http"
      probe_method        = "HEAD"
      interval_in_seconds = 60
    }]

    frontdoor_backend =  [
    {
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
