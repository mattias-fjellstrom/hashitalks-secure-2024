resource "local_file" "vault_env" {
  filename = "vault.env"
  content  = <<-EOF
  VAULT_ADDR="${hcp_vault_cluster.this.vault_public_endpoint_url}"
  VAULT_TOKEN="${hcp_vault_cluster_admin_token.this.token}"
  VAULT_NAMESPACE="admin"
  EOF
}

resource "local_file" "vault_sh" {
  filename        = "vault.sh"
  file_permission = "0777"
  content         = <<-EOF
  #!/bin/bash
  # script to clean up vault resources before destruction
  export VAULT_ADDR="${hcp_vault_cluster.this.vault_public_endpoint_url}"
  export VAULT_TOKEN="${hcp_vault_cluster_admin_token.this.token}"
  export VAULT_NAMESPACE="admin"
  vault lease revoke -force -prefix database/
  vault secrets disable database
  EOF
}

resource "local_file" "boundary" {
  filename = "boundary.env"
  content  = <<-EOF
  BOUNDARY_ADDR="${hcp_boundary_cluster.this.cluster_url}"
  EOF
}
