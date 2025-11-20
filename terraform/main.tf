#############################################
# Resource Group
#############################################
resource "azurerm_resource_group" "frontend" {
  name     = var.resource_group_name
  location = var.location
}

#############################################
# Storage Account (Static Website)
#############################################
resource "azurerm_storage_account" "static" {
  name                     = "st${replace(var.domain_name, ".", "")}site"
  resource_group_name      = azurerm_resource_group.frontend.name
  location                 = azurerm_resource_group.frontend.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  allow_nested_items_to_be_public = false

  blob_properties {
    delete_retention_policy {
      days = 7
    }
  }

  tags = {
    environment = "frontend"
  }
}

#############################################
# Static Website Configuration
#############################################
resource "azurerm_storage_account_static_website" "static" {
  storage_account_id = azurerm_storage_account.static.id

  index_document     = "index.html"
  error_404_document = "index.html"
}

#############################################
# Front Door Profile
#############################################
resource "azurerm_cdn_frontdoor_profile" "frontend" {
  name                = "fd-${var.resource_group_name}"
  resource_group_name = azurerm_resource_group.frontend.name
  sku_name            = "Standard_AzureFrontDoor"
}

#############################################
# Origin Group
#############################################
resource "azurerm_cdn_frontdoor_origin_group" "frontend" {
  name                     = "static-origin-group"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontend.id

  session_affinity_enabled = true

  health_probe {
    interval_in_seconds = 120
    path                = "/"
    protocol            = "Https"
    request_type        = "HEAD"
  }

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
    additional_latency_in_milliseconds = 50
  }
}

#############################################
# Origin (Storage Website Host)
#############################################
resource "azurerm_cdn_frontdoor_origin" "frontend" {
  name                          = "storageorigin"
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontend.id

  host_name                      = azurerm_storage_account.static.primary_web_host
  origin_host_header             = azurerm_storage_account.static.primary_web_host
  https_port                     = 443
  http_port                      = 80
  enabled                        = true
  certificate_name_check_enabled = true
}

#############################################
# Front Door Endpoint
#############################################
resource "azurerm_cdn_frontdoor_endpoint" "frontend" {
  name                     = "${var.cdn_hostname}-${var.resource_group_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontend.id
}

#############################################
# Custom Domains (Validation Only)
#############################################
resource "azurerm_cdn_frontdoor_custom_domain" "root" {
  name                     = "root-domain"
  host_name                = var.domain_name
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontend.id

  tls {
    certificate_type        = "ManagedCertificate"
    minimum_tls_version     = "TLS12"
  }
}

resource "azurerm_cdn_frontdoor_custom_domain" "www" {
  name                     = "www-domain"
  host_name                = "www.${var.domain_name}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.frontend.id

  tls {
    certificate_type        = "ManagedCertificate"
    minimum_tls_version     = "TLS12"
  }
}

#############################################
# Routing Rule
#############################################
resource "azurerm_cdn_frontdoor_route" "frontend" {
  name                          = "route-static"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.frontend.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontend.id

  cdn_frontdoor_origin_ids = [
    azurerm_cdn_frontdoor_origin.frontend.id
  ]

  cdn_frontdoor_custom_domain_ids = [
    azurerm_cdn_frontdoor_custom_domain.root.id,
    azurerm_cdn_frontdoor_custom_domain.www.id
  ]

  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
  https_redirect_enabled = true
  forwarding_protocol    = "HttpsOnly"
  enabled                = true
}
