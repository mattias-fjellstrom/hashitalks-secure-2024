data "github_repository" "this" {
  name = "hashitalks-secure-2024"
}

resource "github_repository_environment" "boundary" {
  environment = "boundary"
  repository  = data.github_repository.this.name
}
