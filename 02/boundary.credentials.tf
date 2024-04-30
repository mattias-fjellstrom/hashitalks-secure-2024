resource "time_sleep" "wait_for_workers" {
  create_duration = "60s"
  depends_on = [
    module.private_worker,
    module.public_worker,
  ]
}

resource "boundary_credential_store_vault" "ec2" {
  name     = "boundary-vault-credential-store-ssh"
  scope_id = boundary_scope.project.id

  address   = data.hcp_vault_cluster.this.vault_private_endpoint_url
  namespace = "admin"
  token     = vault_token.ec2.client_token

  worker_filter = "\"true\" in \"/tags/vault\""

  depends_on = [
    time_sleep.wait_for_workers,
  ]
}

resource "boundary_credential_library_vault_ssh_certificate" "ec2" {
  name                = "ssh-certs"
  credential_store_id = boundary_credential_store_vault.ec2.id
  path                = "ssh-client-signer/sign/boundary-client"

  username = "ubuntu"
  key_type = "ecdsa"
  key_bits = 521
  extensions = {
    permit-pty = ""
  }
}

resource "boundary_credential_store_vault" "postgres" {
  name     = "boundary-vault-credential-store-postgres"
  scope_id = boundary_scope.project.id

  address   = data.hcp_vault_cluster.this.vault_private_endpoint_url
  namespace = "admin"
  token     = vault_token.postgres.client_token

  worker_filter = "\"true\" in \"/tags/vault\""

  depends_on = [
    time_sleep.wait_for_workers,
  ]
}

resource "boundary_credential_library_vault" "write" {
  name                = "write"
  credential_store_id = boundary_credential_store_vault.postgres.id
  path                = "database/creds/write"
}

resource "boundary_credential_library_vault" "read" {
  name                = "read"
  credential_store_id = boundary_credential_store_vault.postgres.id
  path                = "database/creds/read"
}

# BOUNDARY STATIC CREDENTIAL STORE -------------------------------------------------------------------------------------
resource "boundary_credential_store_static" "internal" {
  name     = "boundary-credential-store-static"
  scope_id = boundary_scope.project.id
}

resource "boundary_credential_json" "dummy" {
  name                = "boundary-credentials-json"
  credential_store_id = boundary_credential_store_static.internal.id
  object              = file("./secrets/dummy.json")
}
