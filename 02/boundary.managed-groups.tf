resource "boundary_managed_group" "dba" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for database administrators"
  name           = "dba-group"
  filter         = "\"${azuread_group.dba.object_id}\" in \"/token/groups\""
}

resource "boundary_managed_group" "k8s" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for Kubernetes administrators"
  name           = "k8s-group"
  filter         = "\"${azuread_group.k8s.object_id}\" in \"/token/groups\""
}

resource "boundary_managed_group" "sre" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for site reliability engineers"
  name           = "sre-group"
  filter         = "\"${azuread_group.sre.object_id}\" in \"/token/groups\""
}

resource "boundary_managed_group" "oncall" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for on-call engineers"
  name           = "on-call-group"
  filter         = "\"${azuread_group.oncall.object_id}\" in \"/token/groups\""
}
