# NETWORKING -----------------------------------------------------------------------------------------------------------
resource "aws_security_group" "private_worker" {
  name        = "private-worker"
  description = "Security group for private worker"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "private-worker"
  }
}

resource "aws_security_group_rule" "private_egress_to_vault" {
  description       = "Egress traffic to HCP Vault via peering"
  security_group_id = aws_security_group.private_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 8200
  to_port   = 8200
  cidr_blocks = [
    data.hcp_hvn.this.cidr_block,
  ]
}

resource "aws_security_group_rule" "private_egress_to_public_worker" {
  description       = "Egress traffic to public worker"
  security_group_id = aws_security_group.private_worker.id

  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 9202
  to_port                  = 9202
  source_security_group_id = aws_security_group.public_worker.id
}

resource "aws_security_group_rule" "private_egress_to_ssh_targets" {
  description       = "Egress traffic to SSH targets"
  security_group_id = aws_security_group.private_worker.id

  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 22
  to_port                  = 22
  source_security_group_id = aws_security_group.private_target.id
}

resource "aws_security_group_rule" "private_egress_to_postgres_targets" {
  description       = "Egress traffic to postgres targets"
  security_group_id = aws_security_group.private_worker.id

  type                     = "egress"
  protocol                 = "tcp"
  from_port                = 5432
  to_port                  = 5432
  source_security_group_id = aws_security_group.db.id
}

resource "aws_security_group_rule" "private_egress_to_internet_80" {
  description       = "Egress traffic to the internet (port 80)"
  security_group_id = aws_security_group.private_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 80
  to_port   = 80
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "private_egress_to_internet_443" {
  description       = "Egress traffic to the internet (port 443)"
  security_group_id = aws_security_group.private_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

module "private_worker" {
  source = "./modules/worker/aws"

  worker_name       = "private-worker"
  is_ingress_worker = false
  initial_upstreams = ["${module.public_worker.private_ip}:9202"]
  boundary_worker_tags = {
    type   = "pki"
    vault  = "true"
    subnet = "private"
    cloud  = "aws"
    region = var.aws_region
  }
  boundary_cluster_url = data.hcp_boundary_cluster.this.cluster_url

  aws_region            = var.aws_region
  aws_subnet            = data.aws_subnet.private01
  aws_security_group_id = aws_security_group.private_worker.id

  aws_instance_associate_public_ip_address = false
  aws_instance_profile_name                = aws_iam_instance_profile.workers.name
  aws_instance_type                        = "t3.micro"
  aws_instance_tags = {
    Name = "Boundary Worker (private)"
  }
}
