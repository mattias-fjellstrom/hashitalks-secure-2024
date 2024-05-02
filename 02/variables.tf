variable "aws_region" {
  description = "AWS region name"
  type        = string
}

variable "aws_vpc" {
  description = "The AWS Virtual Private Cloud (VPC)"
  type = object({
    id         = string
    cidr_block = string
  })
}

variable "aws_private_subnets" {
  description = "List of private subnets"
  type = list(object({
    id                = string
    availability_zone = string
    cidr_block        = string
  }))
}

variable "aws_public_subnets" {
  description = "List of public subnets"
  type = list(object({
    id                = string
    availability_zone = string
    cidr_block        = string
  }))
}

variable "aws_rds_master_password" {
  description = "Master password for the RDS database"
  type        = string
  sensitive   = true
}

variable "entra_id_domain" {
  description = "Custom domain name for Entra ID"
  type        = string
}

variable "hcp_boundary_admin_password" {
  description = "Boundary initial admin password"
  type        = string
  sensitive   = true
}

variable "hcp_boundary_cluster_url" {
  description = "HCP Boundary cluster URL"
  type        = string
}

variable "hcp_vault_admin_token" {
  description = "Vault admin token for setting up Vault resources"
  type        = string
  sensitive   = true
}

variable "hcp_vault_cluster_public_url" {
  description = "HCP Vault public URL endpoint"
  type        = string
}

variable "hcp_vault_cluster_private_url" {
  description = "HCP Vault private URL endpoint"
  type        = string
}

variable "hcp_virtual_network_cidr" {
  description = "CIDR block for the HashiCorp Virtual Network (HVN)"
  type        = string
  default     = "192.168.100.0/24"
}
