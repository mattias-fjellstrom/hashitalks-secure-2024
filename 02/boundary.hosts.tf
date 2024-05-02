# EC2 --------------------------------------------------------------------------
resource "boundary_host_catalog_static" "ec2" {
  name     = "AWS EC2 Static Host Catalog"
  scope_id = boundary_scope.project.id
}

resource "boundary_host_static" "ec2" {
  name            = "aws-ec2-private-subnet"
  address         = aws_instance.private_target.private_ip
  host_catalog_id = boundary_host_catalog_static.ec2.id
}

resource "boundary_host_set_static" "ec2" {
  name            = "aws-ec2-static-private-host-set"
  host_catalog_id = boundary_host_catalog_static.ec2.id
  host_ids = [
    boundary_host_static.ec2.id,
  ]
}

# RDS --------------------------------------------------------------------------
resource "boundary_host_catalog_static" "aurora" {
  name     = "AWS Aurora Cluster Catalog"
  scope_id = boundary_scope.project.id
}

resource "boundary_host_static" "postgres" {
  name            = "aws-aurora-postgres"
  address         = aws_rds_cluster.this.endpoint
  host_catalog_id = boundary_host_catalog_static.aurora.id
}

resource "boundary_host_set_static" "aurora" {
  name            = "aws-aurora-static-host-set"
  host_catalog_id = boundary_host_catalog_static.aurora.id
  host_ids = [
    boundary_host_static.postgres.id,
  ]
}
