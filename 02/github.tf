data "github_repository" "this" {
  name = "hashitalks-secure-2024"
}

resource "github_actions_variable" "boundary_username" {
  repository    = data.github_repository.this.name
  variable_name = "BOUNDARY_USERNAME"
  value         = boundary_account_password.github.login_name
}

resource "github_actions_secret" "boundary_password" {
  repository      = data.github_repository.this.name
  secret_name     = "BOUNDARY_PASSWORD"
  plaintext_value = boundary_account_password.github.password
}

resource "github_actions_variable" "boundary_addr" {
  repository    = data.github_repository.this.name
  variable_name = "BOUNDARY_ADDR"
  value         = data.hcp_boundary_cluster.this.cluster_url
}

resource "github_actions_variable" "boundary_auth_method_id" {
  repository    = data.github_repository.this.name
  variable_name = "BOUNDARY_AUTH_METHOD_ID"
  value         = boundary_auth_method_oidc.provider.id
}

resource "github_issue_label" "boundary" {
  name       = "boundary"
  repository = data.github_repository.this.name
  color      = "EC585D"
}
