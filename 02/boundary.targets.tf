resource "boundary_target" "ec2" {
  type                     = "ssh"
  name                     = "aws-ec2-static-private"
  ingress_worker_filter    = "\"public\" in \"/tags/subnet\""
  egress_worker_filter     = "\"private\" in \"/tags/subnet\""
  scope_id                 = boundary_scope.project.id
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
