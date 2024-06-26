# END-USER ROLES -------------------------------------------------------------------------------------------------------
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
    "this", "descendants"
  ]
  principal_ids = [
    boundary_managed_group.all.id,
  ]
}

resource "boundary_role" "ec2" {
  name     = "aws.ec2"
  scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.ec2.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    "this",
  ]
}

resource "boundary_role" "postgres_read" {
  name     = "aws.postgres.read"
  scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.read.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    "this",
  ]
}

resource "boundary_role" "postgres_write" {
  name     = "aws.postgres.write"
  scope_id = boundary_scope.project.id
  grant_strings = [
    "ids=${boundary_target.write.id};actions=read,authorize-session",
  ]
  grant_scope_ids = [
    "this",
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
    "this", "descendants"
  ]
}

# AUTOMATION ROLES -----------------------------------------------------------------------------------------------------
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

resource "boundary_role" "github" {
  name        = "github-automation"
  description = "Role for GitHub issue-ops automation"
  scope_id    = "global"
  grant_strings = [
    "ids=${boundary_role.ec2.id};type=role;actions=read,list,add-principals,remove-principals",
    "ids=${boundary_role.postgres_read.id};type=role;actions=read,list,add-principals,remove-principals",
    "ids=${boundary_role.postgres_write.id};type=role;actions=read,list,add-principals,remove-principals",
    "ids=*;type=user;actions=list,read",
    "ids=*;type=account;actions=read,list",
    "type=role;actions=list",
  ]
  principal_ids = [
    boundary_user.github.id,
  ]
  grant_scope_ids = [
    "this",
    "descendants",
  ]
}
