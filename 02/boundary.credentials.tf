resource "time_sleep" "wait_for_workers" {
  create_duration = "60s"
  depends_on = [
    module.private_worker,
    module.public_worker,
  ]
}

resource "boundary_credential_store_vault" "ec2" {
  name     = "boudary-vault-credential-store-ec2"
  scope_id = boundary_scope.project.id

  // vault settings
  address   = var.hcp_vault_cluster_private_url
  token     = vault_token.boundary.client_token
  namespace = "admin"

  // make sure only workers with access to Vault are used for this credential store
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
