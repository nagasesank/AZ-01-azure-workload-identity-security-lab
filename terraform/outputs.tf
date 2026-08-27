output "current_subscription_id" {
  description = "The subscription ID for the current authenticated Azure context."
  value       = data.azurerm_client_config.current.subscription_id
}

output "current_tenant_id" {
  description = "The tenant ID for the current authenticated Azure context."
  value       = data.azurerm_client_config.current.tenant_id
}

output "current_client_id" {
  description = "The authenticated client or application ID when available from the current Azure context."
  value       = data.azurerm_client_config.current.client_id
  sensitive   = true
}

output "current_object_id" {
  description = "The authenticated object ID when available from the current Azure context."
  value       = data.azurerm_client_config.current.object_id
  sensitive   = true
}

