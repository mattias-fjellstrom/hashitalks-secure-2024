# EC2 --------------------------------------------------------------------------
resource "boundary_host_catalog_static" "ec2" {
  name     = "aws-ec2-static-host-catalog"
  scope_id = boundary_scope.project.id
}

resource "boundary_host_static" "ec2" {
  name            = "aws-ec2"
  address         = aws_instance.private_target.private_ip
  host_catalog_id = boundary_host_catalog_static.ec2.id
}

resource "boundary_host_set_static" "ec2" {
  name            = "aws-ec2-static-host-set"
  host_catalog_id = boundary_host_catalog_static.ec2.id
  host_ids = [
    boundary_host_static.ec2.id,
  ]
}

# RDS --------------------------------------------------------------------------
resource "boundary_host_catalog_static" "aurora" {
  name     = "aws-aurora-static-host-catalog"
  scope_id = boundary_scope.project.id
}

resource "boundary_host_static" "postgres" {
  name            = "aws-postgres"
  address         = aws_rds_cluster.this.endpoint
  host_catalog_id = boundary_host_catalog_static.aurora.id
}

resource "boundary_host_set_static" "aurora" {
  name            = "aws-postgres-static-host-set"
  host_catalog_id = boundary_host_catalog_static.aurora.id
  host_ids = [
    boundary_host_static.postgres.id,
  ]
}
