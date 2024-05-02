data "github_repository" "this" {
  name = "hashitalks-secure-2024"
}

resource "github_actions_variable" "boundary_username" {
  repository    = data.github_repository.this.name
  variable_name = "BOUNDARY_USERNAME"
  value         = boundary_account_password.lambda.login_name
}

resource "github_actions_secret" "boundary_password" {
  repository      = data.github_repository.this.name
  secret_name     = "BOUNDARY_PASSWORD"
  plaintext_value = boundary_account_password.lambda.password
}

resource "github_actions_variable" "boundary_addr" {
  repository    = data.github_repository.this.name
  variable_name = "BOUNDARY_ADDR"
  value         = var.hcp_boundary_cluster_url
}

resource "github_issue_label" "boundary" {
  color      = "EC585D"
  name       = "boundary"
  repository = data.github_repository.this.name
}
