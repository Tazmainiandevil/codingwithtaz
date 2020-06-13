variable "frontdoor_resource_group_name" {
  description = "(Required) Resource Group name"
  type = string
}
variable "frontdoor_resource_group_location" {
  description = "(Required) Resource Group location"
  type = string
}

variable "frontdoor_name" {
  description = "(Required) Name of the Azure Front Door to create"
  type = string
}

variable "frontdoor_loadbalancer_enabled" {
  description = "(Required) Enable the load balancer for Azure Front Door"
  type = bool
}

variable "enforce_backend_pools_certificate_name_check" {
  description = "Enforce the certificate name check for Azure Front Door"
  type = bool
  default = false
}

variable "backend_pools_send_receive_timeout_seconds" {
  description = "Set the send/receive timeout for Azure Front Door"
  type = number
  default = 60
}

variable "custom_https_provisioning_enabled" {
  description = "(Required) Custom HTTPS provising enabled for Azure Front Door"
  type = bool
}

variable "custom_https_configuration" {
  description = "(Required) Custom HTTPS configuration for Azure Front Door"
  type = object({
    certificate_source = string    
  })
}

variable "tags" {
  description = "(Required) Tags for Azure Front Door"  
}

variable "frontdoor_routing_rule" {
  description = "(Required) Routing rules for Azure Front Door"
  type = list(object({
    name = string
    frontend_endpoints = list(string)
    accepted_protocols = list(string)
    patterns_to_match  = list(string)
    enabled            = bool
    configuration      = string
    forwarding_configuration = list(object({
      backend_pool_name                     = string
      cache_enabled                         = bool
      cache_use_dynamic_compression         = bool           
      cache_query_parameter_strip_directive = string
      custom_forwarding_path                = string
      forwarding_protocol                   = string
    }))    
    redirect_configuration = list(object({
      custom_host           = string
      redirect_protocol     = string
      redirect_type         = string
      custom_fragment       = string
      custom_path           = string
      custom_query_string   = string
    }))
  }))  
}

variable "frontdoor_loadbalancer" {
  description = "(Required) Load Balancer settings for Azure Front Door"
  type = list(object({
        name                            = string
        sample_size                     = number
        successful_samples_required     = number
        additional_latency_milliseconds = number
  }))
}

variable "frontdoor_health_probe" {
  description = "(Required) Health Probe settings for Azure Front Door"
  type = list(object({
          name                = string
          enabled             = bool
          path                = string
          protocol            = string
          probe_method        = string    
          interval_in_seconds = number            
  }))
}

variable "frontdoor_backend" {
  description = "(Required) Backend settings for Azure Front Door"
  type = list(object({
      name               = string
      loadbalancing_name = string
      health_probe_name  = string
      backend = list(object({
        enabled     = bool
        host_header = string
        address     = string
        http_port   = number
        https_port  = number
        priority    = number
        weight      = number
      }))
    }))
}
