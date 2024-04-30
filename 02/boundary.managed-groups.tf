resource "boundary_managed_group" "all" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for all users"
  name           = "all-users"
  filter         = "\"${data.azuread_group.all.object_id}\" in \"/token/groups\""
}

resource "boundary_managed_group" "oncall" {
  auth_method_id = boundary_auth_method_oidc.provider.id
  description    = "Group for on-call engineers"
  name           = "on-call-group"
  filter         = "\"${azuread_group.oncall.object_id}\" in \"/token/groups\""
}
