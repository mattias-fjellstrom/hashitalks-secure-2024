resource "boundary_worker" "this" {
  scope_id                    = "global"
  name                        = var.worker_name
  worker_generated_auth_token = ""
}

locals {
  boundary_worker_config = templatefile("${path.module}/worker.hcl.tftpl", {
    is_ingress                            = var.is_ingress_worker
    hcp_boundary_cluster_id               = split(".", split("//", var.boundary_cluster_url)[1])[0]
    initial_upstreams                     = coalesce(var.initial_upstreams, [])
    controller_generated_activation_token = boundary_worker.this.controller_generated_activation_token
    tags                                  = var.boundary_worker_tags
  })

  boundary_worker_service_config = <<-WORKER_SERVICE_CONFIG
  [Unit]
  Description="HashiCorp Boundary - Identity-based access management for dynamic infrastructure"
  Documentation=https://www.boundaryproject.io/docs
  StartLimitIntervalSec=60
  StartLimitBurst=3

  [Service]
  ExecStart=/usr/bin/boundary server -config=/etc/boundary.d/pki-worker.hcl
  ExecReload=/bin/kill --signal HUP $MAINPID
  KillMode=process
  KillSignal=SIGINT
  Restart=on-failure
  RestartSec=5
  TimeoutStopSec=30
  LimitMEMLOCK=infinity

  [Install]
  WantedBy=multi-user.target
WORKER_SERVICE_CONFIG

  cloudinit_config_boundary_worker = {
    write_files = [
      {
        content = local.boundary_worker_service_config
        path    = "/etc/systemd/system/boundary.service"
      },
      {
        content = local.boundary_worker_config
        path    = "/etc/boundary.d/pki-worker.hcl"
      },
    ]
  }

  ip_meta_data_key = var.aws_instance_associate_public_ip_address ? "public" : "local"
  source_for_ip    = "http://169.254.169.254/latest/meta-data/${local.ip_meta_data_key}-ipv4"
}

data "cloudinit_config" "boundary_worker" {
  gzip          = false
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      sudo yum install -y yum-utils shadow-utils
      sudo yum-config-manager --add-repo https://rpm.releases.hashicorp.com/AmazonLinux/hashicorp.repo
      sudo yum -y install boundary-enterprise
      sudo mkdir /etc/boundary.d/worker
    EOF
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash
      curl '${local.source_for_ip}' > /tmp/ip
      export IP1=$(cat /tmp/ip)
      sudo sed -ibak "s/IP/$IP1/g" /etc/boundary.d/pki-worker.hcl
    EOF
  }

  part {
    content_type = "text/cloud-config"
    content      = yamlencode(local.cloudinit_config_boundary_worker)
  }

  part {
    content_type = "text/x-shellscript"
    content      = <<-EOF
      #!/bin/bash

      sudo systemctl daemon-reload
      sudo systemctl enable boundary
      sudo systemctl start boundary
    EOF
  }
}

data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "this" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.aws_instance_type
  vpc_security_group_ids      = [var.aws_security_group_id]
  subnet_id                   = var.aws_subnet.id
  availability_zone           = var.aws_subnet.availability_zone
  associate_public_ip_address = var.aws_instance_associate_public_ip_address
  user_data_base64            = data.cloudinit_config.boundary_worker.rendered
  tags                        = var.aws_instance_tags
  iam_instance_profile        = var.aws_instance_profile_name

  lifecycle {
    ignore_changes = [user_data_base64]
  }
}


