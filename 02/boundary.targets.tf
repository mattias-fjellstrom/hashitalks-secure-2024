resource "boundary_target" "ec2" {
  type                     = "ssh"
  name                     = "aws-ec2-static-private"
  scope_id                 = boundary_scope.project.id
  ingress_worker_filter    = "\"public\" in \"/tags/subnet\""
  egress_worker_filter     = "\"private\" in \"/tags/subnet\""
  session_connection_limit = -1
  default_port             = 22
  host_source_ids = [
    boundary_host_set_static.ec2.id,
  ]
  injected_application_credential_source_ids = [
    boundary_credential_library_vault_ssh_certificate.ec2.id,
  ]
  # uncomment to enable session recording
  #   enable_session_recording = true
  #   storage_bucket_id        = boundary_storage_bucket.session_recording.id
}

resource "boundary_alias_target" "ec2" {
  name                      = "aws-ec2-alias"
  scope_id                  = "global"
  value                     = "aws.ec2"
  destination_id            = boundary_target.ec2.id
  authorize_session_host_id = boundary_host_static.ec2.id
}

resource "boundary_target" "readwrite" {
  type     = "tcp"
  name     = "aws-aurora-read/write"
  scope_id = boundary_scope.project.id

  ingress_worker_filter = "\"public\" in \"/tags/subnet\""
  egress_worker_filter  = "\"private\" in \"/tags/subnet\""

  brokered_credential_source_ids = [
    boundary_credential_library_vault.readwrite.id
  ]
  host_source_ids = [
    boundary_host_set_static.aurora.id,
  ]

  default_port             = 5432
  session_connection_limit = -1
}

resource "boundary_alias_target" "readwrite" {
  name                      = "aws-postgres-readwrite"
  scope_id                  = "global"
  value                     = "aws.postgres.readwrite"
  destination_id            = boundary_target.readwrite.id
  authorize_session_host_id = boundary_host_static.postgres.id
}

resource "boundary_target" "read" {
  type     = "tcp"
  name     = "aws-aurora-read"
  scope_id = boundary_scope.project.id

  ingress_worker_filter = "\"public\" in \"/tags/subnet\""
  egress_worker_filter  = "\"private\" in \"/tags/subnet\""

  brokered_credential_source_ids = [
    boundary_credential_library_vault.read.id
  ]
  host_source_ids = [
    boundary_host_set_static.aurora.id,
  ]

  default_port             = 5432
  session_connection_limit = -1
}

resource "boundary_alias_target" "read" {
  name                      = "aws-postgres-read"
  scope_id                  = "global"
  value                     = "aws.postgres.read"
  destination_id            = boundary_target.read.id
  authorize_session_host_id = boundary_host_static.postgres.id
}
