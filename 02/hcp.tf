data "hcp_hvn" "this" {
  hvn_id = "hvn-aws-${var.aws_region}"
}

data "hcp_vault_cluster" "this" {
  cluster_id = "vault-aws-${var.aws_region}"
}

data "hcp_boundary_cluster" "this" {
  cluster_id = "aws-boundary"
}
