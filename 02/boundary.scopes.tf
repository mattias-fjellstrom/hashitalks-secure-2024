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

# EMPTY SCOPES FOR ILLUSTRATIVE PURPUSE
resource "boundary_scope" "gcp" {
  scope_id                 = boundary_scope.organization.id
  name                     = "gcp-resources"
  description              = "Project for all GCP resources"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "azure" {
  scope_id                 = boundary_scope.organization.id
  name                     = "azure-resources"
  description              = "Project for all GCP resources"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_1" {
  scope_id                 = "global"
  name                     = "Business Unit X"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_1_team_1" {
  scope_id                 = boundary_scope.business_unit_1.id
  name                     = "Team Alpha"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_1_team_2" {
  scope_id                 = boundary_scope.business_unit_1.id
  name                     = "Team Beta"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_1_team_3" {
  scope_id                 = boundary_scope.business_unit_1.id
  name                     = "Team Gamma"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_1_team_4" {
  scope_id                 = boundary_scope.business_unit_1.id
  name                     = "Team Delta"
  auto_create_admin_role   = true
  auto_create_default_role = true
}

resource "boundary_scope" "business_unit_2" {
  scope_id                 = "global"
  name                     = "Business Unit Y"
  auto_create_admin_role   = true
  auto_create_default_role = true
}
