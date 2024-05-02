data "github_repository" "this" {
  name = "hashitalks-secure-2024"
}

resource "github_actions_secret" "boundary_username" {
  repository      = data.github_repository.this.name
  secret_name     = "BOUNDARY_USERNAME"
  plaintext_value = boundary_account_password.lambda.login_name
}

resource "github_actions_secret" "boundary_password" {
  repository      = data.github_repository.this.name
  secret_name     = "BOUNDARY_PASSWORD"
  plaintext_value = boundary_account_password.lambda.password
}
