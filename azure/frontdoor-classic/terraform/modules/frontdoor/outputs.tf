output "frontdoor_routing_rule" {
  value = azurerm_frontdoor.instance.routing_rule
}

output "backend_pool_health_probe" {
  value = azurerm_frontdoor.instance.backend_pool_health_probe
}
