data "azuread_client_config" "current" {}

# USERS AND GROUPS -------------------------------------------------------------

# User must exist in your Entra ID tenant
data "azuread_user" "margarete_gnaw" {
  user_principal_name = "margarete-gnaw@${var.entra_id_domain}"
}

# User must exist in your Entra ID tenant
data "azuread_user" "lane_buckwindow" {
  user_principal_name = "lane-buckwindow@${var.entra_id_domain}"
}

# Group must exist in your Entra ID tenant
data "azuread_group" "all" {
  display_name = "All Users"
}

resource "azuread_group" "oncall" {
  display_name     = "On-Call Engineers"
  security_enabled = true

  members = [
    data.azuread_user.lane_buckwindow.object_id,
    data.azuread_user.margarete_gnaw.object_id,
  ]
}

# OIDC SETUP -------------------------------------------------------------------
data "azuread_application_published_app_ids" "well_known" {}

resource "azuread_service_principal" "msgraph" {
  client_id    = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph
  use_existing = true
}

resource "azuread_application" "oidc" {
  display_name = "HCP Boundary OIDC"

  required_resource_access {
    resource_app_id = data.azuread_application_published_app_ids.well_known.result.MicrosoftGraph

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["User.Read.All"]
      type = "Scope"
    }

    resource_access {
      id   = azuread_service_principal.msgraph.oauth2_permission_scope_ids["GroupMember.Read.All"]
      type = "Scope"
    }
  }

  group_membership_claims = ["All"]

  web {
    redirect_uris = ["${data.hcp_boundary_cluster.this.cluster_url}/v1/auth-methods/oidc:authenticate:callback"]
    logout_url    = "${data.hcp_boundary_cluster.this.cluster_url}:3000"
  }
}

resource "azuread_service_principal" "oidc" {
  client_id = azuread_application.oidc.client_id
}

resource "azuread_service_principal_delegated_permission_grant" "this" {
  service_principal_object_id          = azuread_service_principal.oidc.object_id
  resource_service_principal_object_id = azuread_service_principal.msgraph.object_id
  claim_values                         = ["User.Read.All", "GroupMember.Read.All"]
}

resource "azuread_application_password" "oidc" {
  application_id    = azuread_application.oidc.id
  end_date_relative = "2160h" // 90 days
}
