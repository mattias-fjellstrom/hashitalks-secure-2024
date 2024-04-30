resource "boundary_group" "automation" {
  name     = "automation-users"
  scope_id = "global"
  member_ids = [
    boundary_user.github.id,
    boundary_user.lambda.id,
  ]
}
