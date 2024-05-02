resource "local_file" "vault" {
  filename = "vault.env"
  content  = <<-EOF
  VAULT_ADDR="${hcp_vault_cluster.this.vault_public_endpoint_url}"
  VAULT_TOKEN="${hcp_vault_cluster_admin_token.this.token}"
  VAULT_NAMESPACE="admin"
  EOF
}

resource "local_file" "boundary" {
  filename = "boundary.env"
  content  = <<-EOF
  BOUNDARY_ADDR="${hcp_boundary_cluster.this.cluster_url}"
  EOF
}
