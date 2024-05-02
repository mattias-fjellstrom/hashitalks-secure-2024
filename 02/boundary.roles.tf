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

resource "boundary_role" "dba_admin" {
  name     = "dba-admin"
  scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.read.id};actions=read,authorize-session",
    "ids=${boundary_target.readwrite.id};actions=read,authorize-session",
  ]
  principal_ids = [
    boundary_managed_group.dba.id,
  ]
}

resource "boundary_role" "oncall" {
  name        = "on-call"
  description = "Role for on-call engineers"
  grant_strings = [
    "ids=*;type=*;actions=read,list",
    "ids=*;type=target;actions=authorize-session",
  ]
  grant_scope_ids = [
    boundary_scope.project.id,
  ]
  scope_id = "global"
}

resource "boundary_role" "lambda" {
  name        = "aws-lambda-admin"
  description = "Role for AWS Lambda to administer the on-call role assignment"
  grant_strings = [
    "ids=${boundary_role.oncall.id};type=role;actions=read,list,add-principals,remove-principals",
  ]
  principal_ids = [
    boundary_user.lambda.id,
  ]
  scope_id = "global"
}
