resource "boundary_role" "reader" {
  name        = "reader"
  description = "Basic reader role for all managed groups"
  scope_id    = boundary_scope.project.id

  grant_strings = [
    "ids=*;type=*;actions=list,no-op",
    "ids=*;type=session;actions=read:self,cancel:self",
    "ids=*;type=auth-token;actions=list,read:self,delete:self",
  ]

  principal_ids = [
    boundary_managed_group.dba.id,
    boundary_managed_group.k8s.id,
    boundary_managed_group.sre.id,
  ]
}
