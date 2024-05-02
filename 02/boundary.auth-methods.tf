resource "boundary_auth_method_oidc" "provider" {
  name                 = "Entra ID"
  description          = "OIDC auth method for Entra ID"
  scope_id             = boundary_scope.project.scope_id
  issuer               = "https://sts.windows.net/${data.azuread_client_config.current.tenant_id}/"
  client_id            = azuread_application.oidc.client_id
  client_secret        = azuread_application_password.oidc.value
  signing_algorithms   = ["RS256"]
  api_url_prefix       = var.hcp_boundary_cluster_url
  is_primary_for_scope = true
  state                = "active-public"
  claims_scopes        = ["groups"]
}

data "boundary_auth_method" "password" {
  name = "password"
}
