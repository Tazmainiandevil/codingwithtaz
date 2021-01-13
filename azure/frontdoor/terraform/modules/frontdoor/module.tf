# Create front door
resource "azurerm_frontdoor" "instance" {
  name                                         = var.frontdoor_name
  resource_group_name                          = var.frontdoor_resource_group_name
  enforce_backend_pools_certificate_name_check = var.enforce_backend_pools_certificate_name_check
  load_balancer_enabled                        = var.frontdoor_loadbalancer_enabled
  backend_pools_send_receive_timeout_seconds   = var.backend_pools_send_receive_timeout_seconds
  tags                                         = var.tags

  dynamic "backend_pool_load_balancing" {
    for_each = var.frontdoor_loadbalancer
    content {
      name                            = backend_pool_load_balancing.value.name
      sample_size                     = backend_pool_load_balancing.value.sample_size
      successful_samples_required     = backend_pool_load_balancing.value.successful_samples_required
      additional_latency_milliseconds = backend_pool_load_balancing.value.additional_latency_milliseconds
    }
  }

  dynamic "routing_rule" {
    for_each = var.frontdoor_routing_rule
    content {
        name               = routing_rule.value.name
        accepted_protocols = routing_rule.value.accepted_protocols
        patterns_to_match  = routing_rule.value.patterns_to_match
        frontend_endpoints = values({for x, endpoint in var.frontend_endpoint : x => endpoint.name})
        dynamic "forwarding_configuration" {
          for_each = routing_rule.value.configuration == "Forwarding" ? routing_rule.value.forwarding_configuration : []
          content {
            backend_pool_name                     = forwarding_configuration.value.backend_pool_name
            cache_enabled                         = forwarding_configuration.value.cache_enabled
            cache_use_dynamic_compression         = forwarding_configuration.value.cache_use_dynamic_compression #default: false
            cache_query_parameter_strip_directive = forwarding_configuration.value.cache_query_parameter_strip_directive
            custom_forwarding_path                = forwarding_configuration.value.custom_forwarding_path
            forwarding_protocol                   = forwarding_configuration.value.forwarding_protocol
          }
        }
        dynamic "redirect_configuration" {
          for_each = routing_rule.value.configuration == "Redirecting" ? routing_rule.value.redirect_configuration : []
          content {
            custom_host         = redirect_configuration.value.custom_host
            redirect_protocol   = redirect_configuration.value.redirect_protocol
            redirect_type       = redirect_configuration.value.redirect_type
            custom_fragment     = redirect_configuration.value.custom_fragment
            custom_path         = redirect_configuration.value.custom_path
            custom_query_string = redirect_configuration.value.custom_query_string
          }
        }
    }
  }

 dynamic "backend_pool_health_probe" {
    for_each = var.frontdoor_health_probe
    content {
      name                = backend_pool_health_probe.value.name
      enabled             = backend_pool_health_probe.value.enabled
      path                = backend_pool_health_probe.value.path
      protocol            = backend_pool_health_probe.value.protocol
      probe_method        = backend_pool_health_probe.value.probe_method
      interval_in_seconds = backend_pool_health_probe.value.interval_in_seconds
    }
  }

  dynamic "backend_pool" {
    for_each = var.frontdoor_backend
    content {
       name                = backend_pool.value.name
       load_balancing_name = backend_pool.value.loadbalancing_name
       health_probe_name   = backend_pool.value.health_probe_name

       dynamic "backend" {
        for_each = backend_pool.value.backend
        content {
          enabled     = backend.value.enabled
          address     = backend.value.address
          host_header = backend.value.host_header
          http_port   = backend.value.http_port
          https_port  = backend.value.https_port
          priority    = backend.value.priority
          weight      = backend.value.weight
        }
      }
    }
  }

  dynamic "frontend_endpoint" {
    for_each = var.frontend_endpoint
    content {
      name                                    = frontend_endpoint.value.name
      host_name                               = frontend_endpoint.value.host_name
      custom_https_provisioning_enabled       = frontend_endpoint.value.custom_https_provisioning_enabled
      session_affinity_enabled                = frontend_endpoint.value.session_affinity_enabled
      session_affinity_ttl_seconds            = frontend_endpoint.value.session_affinity_ttl_seconds
      web_application_firewall_policy_link_id = frontend_endpoint.value.waf_policy_link_id
      dynamic "custom_https_configuration" {
        for_each = frontend_endpoint.value.custom_https_provisioning_enabled == false ? [] : list(frontend_endpoint.value.custom_https_configuration.certificate_source)
        content {
          certificate_source = frontend_endpoint.value.custom_https_configuration.certificate_source
        }
      }
    }
  }
}
