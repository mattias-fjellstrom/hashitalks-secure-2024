resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "ec2" {
  key_name   = "boundary-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "local_file" "pem" {
  filename        = "workers.pem"
  file_permission = "0400"
  content         = tls_private_key.this.private_key_pem
}
