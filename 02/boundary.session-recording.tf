resource "boundary_storage_bucket" "session_recording" {
  name        = "hashitalks-session-recordings"
  scope_id    = boundary_scope.organization.id
  plugin_name = "aws"
  bucket_name = aws_s3_bucket.session_recording.bucket

  attributes_json = jsonencode({
    "region"                      = var.aws_region
    "role_arn"                    = aws_iam_role.workers.arn
    "disable_credential_rotation" = true
  })

  worker_filter = "\"/tags/subnet/0\" == \"public\""

  # alternative (but equivalent) filter
  # worker_filter = "\"public\" in \"/tags/subnet\""

  depends_on = [
    time_sleep.wait_for_workers,
  ]
}

resource "boundary_policy_storage" "session_recording" {
  name              = "hashitalks-storage-policy"
  scope_id          = "global"
  delete_after_days = 2
  retain_for_days   = 1
}
