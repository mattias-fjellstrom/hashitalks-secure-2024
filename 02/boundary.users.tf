resource "random_password" "lambda" {
  upper   = true
  lower   = true
  numeric = true
  special = false
  length  = 32
}

resource "boundary_account_password" "lambda" {
  name           = "aws-lambda-admin"
  description    = "Account for AWS Lambda for on-call administration"
  auth_method_id = data.boundary_auth_method.password.id
  login_name     = "aws-lambda"
  password       = random_password.lambda.result
}

resource "boundary_user" "lambda" {
  name        = "aws-lambda-admin"
  description = "User for AWS Lambda for on-call administration"
  scope_id    = "global"
  account_ids = [
    boundary_account_password.lambda.id
  ]
}

# OIDC accounts
resource "boundary_account_oidc" "hashitalks_john" {
  name           = data.azuread_user.lane_buckwindow.mail_nickname
  auth_method_id = boundary_auth_method_oidc.provider.id
  issuer         = boundary_auth_method_oidc.provider.issuer
  subject        = data.azuread_user.lane_buckwindow.object_id
}

resource "boundary_account_oidc" "margarete_gnaw" {
  name           = data.azuread_user.margarete_gnaw.mail_nickname
  auth_method_id = boundary_auth_method_oidc.provider.id
  issuer         = boundary_auth_method_oidc.provider.issuer
  subject        = data.azuread_user.margarete_gnaw.object_id
}
