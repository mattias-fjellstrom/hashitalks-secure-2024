resource "boundary_role" "reader" {
  name        = "reader"
  description = "Basic reader role for all managed groups"
  scope_id    = "global"
  grant_strings = [
    "ids=*;type=scope;actions=list,no-op",
    "ids=*;type=session;actions=read:self,cancel:self",
    "ids=*;type=auth-token;actions=list,read:self,delete:self",
  ]
  grant_scope_ids = [
    boundary_scope.organization.id,
    boundary_scope.project.id,
  ]
  principal_ids = [
    boundary_managed_group.all.id,
  ]
}

resource "boundary_role" "ec2" {
  name        = "aws.ec2"
  description = "Allow connections to EC2 targets"
  scope_id    = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.ec2.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    boundary_scope.project.id,
  ]
}

resource "boundary_role" "postgres_read" {
  name        = "aws.postgres.read"
  description = "Allow connections to Postgres read-targets"
  scope_id    = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.read.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    boundary_scope.project.id,
  ]
}

resource "boundary_role" "postgres_readwrite" {
  name        = "aws.postgres.readwrite"
  description = "Allow connections to Postgres read/write-targets"
  scope_id    = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.readwrite.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    boundary_scope.project.id,
  ]
}

resource "boundary_role" "oncall" {
  name        = "on-call"
  description = "Role for on-call engineers"
  scope_id    = "global"
  grant_strings = [
    "ids=*;type=target;actions=read,authorize-session",
  ]
  grant_scope_ids = [
    boundary_scope.project.id,
  ]
}

resource "boundary_role" "lambda" {
  name        = "aws-lambda-admin"
  description = "Role for AWS Lambda to administer the on-call role assignment"
  scope_id    = "global"
  grant_strings = [
    "ids=${boundary_role.oncall.id};type=role;actions=read,list,add-principals,remove-principals",
  ]
  principal_ids = [
    boundary_user.lambda.id,
  ]
}
