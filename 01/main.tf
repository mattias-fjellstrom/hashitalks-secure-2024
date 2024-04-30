resource "local_file" "vault_sh" {
  filename        = "vault.sh"
  file_permission = "0777"
  content         = <<-EOF
  #!/bin/bash
  # script to clean up vault resources before destruction otherwise terraform destroy will fail
  export VAULT_ADDR="${hcp_vault_cluster.this.vault_public_endpoint_url}"
  export VAULT_TOKEN="${hcp_vault_cluster_admin_token.this.token}"
  export VAULT_NAMESPACE="admin"
  vault lease revoke -force -prefix database/
  vault secrets disable database
  EOF
}
