output "frontdoor_hostname" {
  description = "Front Door endpoint hostname"
  value       = azurerm_cdn_frontdoor_endpoint.frontend.host_name
}

output "static_site_url" {
  description = "Primary static website endpoint"
  value       = azurerm_storage_account.static.primary_web_endpoint
}
