resource "boundary_scope" "organization" {
  scope_id                 = "global"
  name                     = "hashitalks-secure-2024-organization"
  description              = "Organization for HashiTalks Secure 2024 demo"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "project" {
  scope_id                 = boundary_scope.organization.id
  name                     = "aws-resources"
  description              = "Project for all demo AWS resources"
  auto_create_admin_role   = true
  auto_create_default_role = true
}
