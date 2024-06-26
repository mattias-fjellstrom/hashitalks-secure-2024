resource "aws_db_subnet_group" "this" {
  name = "aurora-subnet-group"
  subnet_ids = [
    data.aws_subnet.private01.id,
    data.aws_subnet.private02.id,
    data.aws_subnet.private03.id,
  ]

  tags = {
    Name = "Aurora"
  }
}

resource "aws_security_group" "db" {
  name        = "aurora"
  description = "Security group for Aurora postgresql serverless cluster"
  vpc_id      = data.aws_vpc.this.id

  tags = {
    Name = "Aurora DB"
  }
}

resource "aws_security_group_rule" "db_ingress_from_private_worker" {
  description       = "Allow traffic from private worker"
  security_group_id = aws_security_group.db.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  source_security_group_id = aws_security_group.private_worker.id
}

resource "aws_security_group_rule" "db_ingress_from_vault" {
  description       = "Allow traffic from vault"
  security_group_id = aws_security_group.db.id

  type      = "ingress"
  protocol  = "tcp"
  from_port = 5432
  to_port   = 5432

  cidr_blocks = [
    data.hcp_hvn.this.cidr_block,
  ]
}

data "aws_rds_engine_version" "postgresql" {
  engine  = "aurora-postgresql"
  version = "16.1"
}

resource "aws_rds_cluster_parameter_group" "postgres" {
  name   = "aurora-postgres-boundary"
  family = data.aws_rds_engine_version.postgresql.parameter_group_family

  parameter {
    name  = "log_connections"
    value = "1"
  }

  parameter {
    apply_method = "pending-reboot"
    name         = "rds.force_ssl"
    value        = "0"
  }
}

resource "aws_rds_cluster" "this" {
  availability_zones = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1],
    data.aws_availability_zones.available.names[2],
  ]

  cluster_identifier              = "aurora-${var.aws_region}"
  database_name                   = "appdb"
  db_subnet_group_name            = aws_db_subnet_group.this.name
  engine                          = data.aws_rds_engine_version.postgresql.engine
  engine_mode                     = "provisioned"
  engine_version                  = data.aws_rds_engine_version.postgresql.version
  master_username                 = "boundary"
  master_password                 = var.aws_rds_master_password
  storage_encrypted               = true
  skip_final_snapshot             = true
  vpc_security_group_ids          = [aws_security_group.db.id]
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.postgres.name

  serverlessv2_scaling_configuration {
    max_capacity = 1.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "this" {
  cluster_identifier  = aws_rds_cluster.this.id
  instance_class      = "db.serverless"
  engine              = aws_rds_cluster.this.engine
  engine_version      = aws_rds_cluster.this.engine_version
  publicly_accessible = false
}
