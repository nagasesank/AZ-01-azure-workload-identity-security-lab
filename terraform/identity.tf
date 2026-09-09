resource "azuread_application" "workload" {
  display_name     = "az01-workload-identity-lab"
  sign_in_audience = "AzureADMyOrg"
  owners           = [data.azuread_client_config.current.object_id]
}

resource "azuread_service_principal" "workload" {
  client_id = azuread_application.workload.client_id
  owners    = [data.azuread_client_config.current.object_id]
}

# Trust only this repository's main branch to exchange a GitHub OIDC token.
resource "azuread_application_federated_identity_credential" "github_main" {
  application_id = azuread_application.workload.id
  display_name   = "az01-github-main-oidc"
  description    = "GitHub Actions OIDC trust for AZ-01 main branch"
  audiences      = ["api://AzureADTokenExchange"]
  issuer         = "https://token.actions.githubusercontent.com"
  subject        = "repo:nagasesank@67413218/AZ-01-azure-workload-identity-security-lab@1348063865:ref:refs/heads/main"
}
