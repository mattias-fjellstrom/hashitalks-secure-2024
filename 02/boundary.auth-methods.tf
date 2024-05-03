resource "boundary_auth_method_oidc" "provider" {
  name                 = "Entra ID"
  scope_id             = boundary_scope.project.scope_id
  is_primary_for_scope = true
  state                = "active-private"

  client_id          = azuread_application.oidc.client_id
  client_secret      = azuread_application_password.oidc.value
  issuer             = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/"
  signing_algorithms = ["RS256"]
  api_url_prefix     = var.hcp_boundary_cluster_url
  claims_scopes      = ["groups"]
  prompts            = ["select_account"]
}

data "boundary_auth_method" "password" {
  name = "password"
}
