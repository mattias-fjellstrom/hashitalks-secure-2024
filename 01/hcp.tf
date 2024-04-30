# NETWORKING -------------------------------------------------------------------
resource "hcp_hvn" "this" {
  hvn_id         = "hvn-aws-${var.aws_region}"
  cidr_block     = var.hcp_virtual_network_cidr
  cloud_provider = "aws"
  region         = var.aws_region
}

resource "hcp_aws_network_peering" "this" {
  hvn_id          = hcp_hvn.this.hvn_id
  peering_id      = "hcp-aws"
  peer_vpc_id     = aws_vpc.this.id
  peer_account_id = aws_vpc.this.owner_id
  peer_vpc_region = var.aws_region
}

resource "hcp_hvn_route" "this" {
  hvn_link         = hcp_hvn.this.self_link
  hvn_route_id     = "aws"
  destination_cidr = aws_vpc.this.cidr_block
  target_link      = hcp_aws_network_peering.this.self_link
}

resource "aws_vpc_peering_connection_accepter" "this" {
  vpc_peering_connection_id = hcp_aws_network_peering.this.provider_peering_id
  auto_accept               = true
}

# VAULT ------------------------------------------------------------------------
resource "hcp_vault_cluster" "this" {
  cluster_id      = "vault-aws-${var.aws_region}"
  hvn_id          = hcp_hvn.this.hvn_id
  tier            = "dev"
  public_endpoint = true
}

resource "hcp_vault_cluster_admin_token" "this" {
  cluster_id = hcp_vault_cluster.this.cluster_id
}

# BOUNDARY ---------------------------------------------------------------------
resource "hcp_boundary_cluster" "this" {
  cluster_id = "aws-boundary"
  username   = "admin"
  password   = var.hcp_boundary_admin_password
  tier       = "Plus"

  maintenance_window_config {
    day          = "TUESDAY"
    start        = 2
    end          = 12
    upgrade_type = "SCHEDULED"
  }
}
