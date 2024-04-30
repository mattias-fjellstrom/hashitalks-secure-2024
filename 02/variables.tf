variable "aws_rds_master_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}

variable "aws_region" {
  description = "AWS region name"
  type        = string
}

variable "entra_id_domain" {
  description = "Custom domain name for Entra ID"
  type        = string
}

variable "github_organization" {
  description = "GitHub organization name"
  type        = string
}

variable "hcp_boundary_admin_password" {
  description = "Boundary initial admin password"
  type        = string
  sensitive   = true
}

variable "hcp_vault_admin_token" {
  description = "Vault admin token for setting up Vault resources"
  type        = string
  sensitive   = true
}
