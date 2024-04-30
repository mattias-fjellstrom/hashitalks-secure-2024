data "azuread_client_config" "current" {}

# USERS AND GROUPS -------------------------------------------------------------
resource "azuread_user" "dba" {
  user_principal_name = "dba@${var.entra_id_domain}"
  display_name        = "David B. Andersson"
  mail_nickname       = "dba"
  password            = var.hcp_boundary_admin_password
}

resource "azuread_user" "sre" {
  user_principal_name = "sre@${var.entra_id_domain}"
  display_name        = "Sarah R. Ericson"
  mail_nickname       = "sre"
  password            = var.hcp_boundary_admin_password
}

resource "azuread_user" "k8s" {
  user_principal_name = "k8s@${var.entra_id_domain}"
  display_name        = "Kenny Eight Soleman"
  mail_nickname       = "k8s"
  password            = var.hcp_boundary_admin_password
}

resource "azuread_user" "oncall" {
  user_principal_name = "oncall@${var.entra_id_domain}"
  display_name        = "Jon Call"
  mail_nickname       = "oncall"
  password            = var.hcp_boundary_admin_password
}

resource "azuread_group" "dba" {
  display_name     = "Database Administrators"
  description      = "Handle anything to do with database administration"
  security_enabled = true
  members = [
    azuread_user.dba.object_id
  ]
}

resource "azuread_group" "sre" {
  display_name     = "Site Reliability Engineers"
  description      = "On-call engineers requiring specific access"
  security_enabled = true
  members = [
    azuread_user.sre.object_id
  ]
}

resource "azuread_group" "k8s" {
  display_name     = "Kubernetes Administrators"
  description      = "Handle Kubernetes cluster administration"
  security_enabled = true
  members = [
    azuread_user.k8s.object_id
  ]
}

resource "azuread_group" "oncall" {
  display_name     = "On-call"
  description      = "Engineers on-call"
  security_enabled = true
  members = [
    azuread_user.oncall.object_id
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
    redirect_uris = ["${var.hcp_boundary_cluster_url}/v1/auth-methods/oidc:authenticate:callback"]
    logout_url    = "${var.hcp_boundary_cluster_url}:3000"
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
