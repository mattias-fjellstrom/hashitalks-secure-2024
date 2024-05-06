# NETWORKING -----------------------------------------------------------------------------------------------------------
resource "aws_security_group" "public_worker" {
  name        = "public-worker"
  description = "Security group for public worker"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "public-worker"
  }
}

resource "aws_security_group_rule" "public_ingress_from_boundary_clients" {
  description       = "Ingress traffic from Boundary clients"
  security_group_id = aws_security_group.public_worker.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 9202
  to_port   = 9202
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "public_ingress_from_private_worker" {
  description       = "Ingress traffic from private worker"
  security_group_id = aws_security_group.public_worker.id

  type                     = "ingress"
  protocol                 = "tcp"
  from_port                = 9202
  to_port                  = 9202
  source_security_group_id = aws_security_group.private_worker.id
}

resource "aws_security_group_rule" "public_egress_to_hcp" {
  description       = "Egress traffic to HCP Boundary control plane"
  security_group_id = aws_security_group.public_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 9201
  to_port   = 9202
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "public_egress_to_internet_80" {
  description       = "Egress traffic to the internet (port 80)"
  security_group_id = aws_security_group.public_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 80
  to_port   = 80
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "public_egress_to_internet_443" {
  description       = "Egress traffic to the internet (port 443)"
  security_group_id = aws_security_group.public_worker.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

# WORKER INSTANCE ------------------------------------------------------------------------------------------------------
resource "boundary_worker" "public" {
  scope_id                    = "global"
  name                        = "public-worker"
  worker_generated_auth_token = ""
}

locals {
  public_worker_config = templatefile("./templates/worker.hcl.tftpl", {
    is_ingress                            = true
    hcp_boundary_cluster_id               = split(".", split("//", data.hcp_boundary_cluster.this.cluster_url)[1])[0]
    audit_enabled                         = true
    observations_enabled                  = true
    sysevents_enabled                     = true
    initial_upstreams                     = [] # leave empty for ingress worker (HCP is upstream)
    controller_generated_activation_token = boundary_worker.public.controller_generated_activation_token

    tags = {
      type   = "pki"
      subnet = "public"
      vaule  = "false"
      cloud  = "aws"
      region = var.aws_region
    }
  })
}

module "public_worker" {
  source = "./modules/worker/aws"

  aws_region            = var.aws_region
  aws_subnet            = data.aws_subnet.public01
  aws_security_group_id = aws_security_group.public_worker.id

  aws_instance_associate_public_ip_address = true
  aws_instance_profile_name                = aws_iam_instance_profile.workers.name
  aws_instance_type                        = "t3.micro"
  aws_instance_tags = {
    Name = "Boundary Worker (public)"
  }

  boundary_worker_config = local.public_worker_config
}
