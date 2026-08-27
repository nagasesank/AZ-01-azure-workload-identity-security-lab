resource "azuread_application" "vulnerable_workload" {
  display_name     = "az01-workload-identity-lab"
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "vulnerable_workload" {
  client_id = azuread_application.vulnerable_workload.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# This intentionally vulnerable credential is limited to the future controlled lab phase.
resource "azuread_application_password" "vulnerable_workload" {
  application_id = azuread_application.vulnerable_workload.id
  display_name   = "az01-vulnerable-phase-temporary-password"
  end_date       = timeadd(timestamp(), "168h")

  # Keep the initially generated seven-day expiration rather than rotating on later plans.
  lifecycle {
    ignore_changes = [end_date]
  }
}
