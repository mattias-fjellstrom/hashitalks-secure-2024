terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }

    azuread = {
      source  = "hashicorp/azuread"
      version = "2.47.0"
    }

    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.14"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }

    vault = {
      source  = "hashicorp/vault"
      version = "4.2.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "boundary" {
  addr                   = var.hcp_boundary_cluster_url
  auth_method_login_name = "admin"
  auth_method_password   = var.hcp_boundary_admin_password
}

provider "vault" {
  address = var.hcp_vault_cluster_public_url
  token   = var.hcp_vault_admin_token
}
