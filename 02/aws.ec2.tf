data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ami" "ubuntu_ami" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical account ID
}

resource "aws_security_group" "private_target" {
  name        = "private-target"
  description = "Security group for static private target"
  vpc_id      = var.aws_vpc.id

  tags = {
    Name = "Static EC2 (private)"
  }
}

resource "aws_security_group_rule" "target_ingress_from_private_worker" {
  description       = "Allow SSH ingress from private workers"
  security_group_id = aws_security_group.private_target.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 22
  to_port   = 22

  source_security_group_id = aws_security_group.private_worker.id
}

resource "aws_security_group_rule" "target_egress_to_public_vault" {
  description       = "Egress traffic to public Vault (for setup)"
  security_group_id = aws_security_group.private_target.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 8200
  to_port   = 8200
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "target_egress_to_internet_80" {
  description       = "Egress traffic to the internet (port 80)"
  security_group_id = aws_security_group.private_target.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 80
  to_port   = 80
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

resource "aws_security_group_rule" "target_egress_to_internet_443" {
  description       = "Egress traffic to the internet (port 443)"
  security_group_id = aws_security_group.private_target.id

  type      = "egress"
  protocol  = "tcp"
  from_port = 443
  to_port   = 443
  cidr_blocks = [
    "0.0.0.0/0",
  ]
}

data "http" "public_key" {
  method = "GET"
  url    = "${var.hcp_vault_cluster_public_url}/v1/ssh-client-signer/public_key"
  request_headers = {
    "X-Vault-Namespace" = "admin"
  }

  retry {
    attempts     = 10
    max_delay_ms = 5000
    min_delay_ms = 1000
  }

  depends_on = [
    vault_mount.ssh,
    vault_ssh_secret_backend_ca.ssh_backend,
    vault_ssh_secret_backend_role.boundary_client
  ]
}

data "cloudinit_config" "ec2" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      echo "${data.http.public_key.response_body}" >> /etc/ssh/trusted-user-ca-keys.pem
      echo 'TrustedUserCAKeys /etc/ssh/trusted-user-ca-keys.pem' | sudo tee -a /etc/ssh/sshd_config
      sudo systemctl restart sshd.service
    EOF
  }
}

resource "aws_instance" "private_target" {
  ami           = data.aws_ami.ubuntu_ami.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [
    aws_security_group.private_target.id,
  ]
  subnet_id                   = var.aws_private_subnets[0].id
  user_data_base64            = data.cloudinit_config.ec2.rendered
  associate_public_ip_address = false

  # TODO delete
  key_name = aws_key_pair.ec2.key_name

  tags = {
    Name = "Boundary Target (public)"
  }
}
