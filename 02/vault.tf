resource "vault_policy" "boundary_controller" {
  name   = "boundary-controller"
  policy = file("policy/boundary-controller-policy.hcl")
}

resource "vault_policy" "ssh" {
  name   = "ssh"
  policy = file("policy/ssh-policy.hcl")
}

resource "vault_mount" "ssh" {
  path = "ssh-client-signer"
  type = "ssh"
}

resource "vault_ssh_secret_backend_role" "boundary_client" {
  name                    = "boundary-client"
  backend                 = vault_mount.ssh.path
  key_type                = "ca"
  default_user            = "ubuntu"
  allowed_users           = "*"
  allowed_extensions      = "*"
  allow_host_certificates = true
  allow_user_certificates = true

  default_extensions = {
    permit-pty = ""
  }
}

resource "vault_ssh_secret_backend_ca" "ssh_backend" {
  backend              = vault_mount.ssh.path
  generate_signing_key = true
}

resource "vault_token" "ec2" {
  display_name = "ec2"
  policies = [
    vault_policy.boundary_controller.name, # allow self-administration of the token
    vault_policy.ssh.name,                 # allow working with the SSH secrets engine
  ]
  no_default_policy = true
  no_parent         = true
  renewable         = true
  ttl               = "24h"
  period            = "1h"
}

# POSTGRES (AWS) -------------------------------------------------------------------------------------------------------
resource "vault_database_secrets_mount" "postgres" {
  path = "database"

  postgresql {
    name                 = "postgres"
    username             = "boundary"
    password             = var.aws_rds_master_password
    connection_url       = "postgresql://{{username}}:{{password}}@${aws_rds_cluster.this.endpoint}:5432/appdb?sslmode=disable"
    verify_connection    = false
    max_open_connections = 5

    allowed_roles = [
      "readwrite",
      "read",
    ]
  }
}

resource "vault_database_secret_backend_role" "readwrite" {
  name    = "readwrite"
  backend = vault_database_secrets_mount.postgres.path
  db_name = vault_database_secrets_mount.postgres.postgresql[0].name

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT CONNECT ON DATABASE appdb TO \"{{name}}\";",
    "REVOKE ALL ON SCHEMA public FROM \"{{name}}\";",
    "GRANT CREATE ON SCHEMA public TO \"{{name}}\";",
    "GRANT ALL ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";",
    "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON TABLES TO \"{{name}}\";",
    "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT ALL ON SEQUENCES TO \"{{name}}\";",
  ]

  default_ttl = 180
  max_ttl     = 300
}

resource "vault_database_secret_backend_role" "read" {
  name    = "read"
  backend = vault_database_secrets_mount.postgres.path
  db_name = vault_database_secrets_mount.postgres.postgresql[0].name

  creation_statements = [
    "CREATE ROLE \"{{name}}\" WITH LOGIN PASSWORD '{{password}}' VALID UNTIL '{{expiration}}' INHERIT;",
    "GRANT CONNECT ON DATABASE appdb TO \"{{name}}\";",
    "REVOKE ALL ON SCHEMA public FROM \"{{name}}\";",
    "GRANT SELECT ON ALL TABLES IN SCHEMA public TO \"{{name}}\";",
    "GRANT SELECT ON ALL SEQUENCES IN SCHEMA public TO \"{{name}}\";",
    "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO \"{{name}}\";",
    "ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON SEQUENCES TO \"{{name}}\";",
    "REVOKE CREATE ON SCHEMA public FROM \"{{name}}\";",
  ]

  default_ttl = 180
  max_ttl     = 300
}

resource "vault_policy" "aurora_database" {
  name   = "postgres-database"
  policy = file("policy/postgres-policy.hcl")
}

resource "vault_token" "postgres" {
  display_name = "postgres"
  policies = [
    "boundary-controller", # manage token
    "postgres-database",   # work with the postgres secrets engine
  ]

  no_default_policy = true
  no_parent         = true
  renewable         = true
  ttl               = "24h"
  period            = "1h"
}
