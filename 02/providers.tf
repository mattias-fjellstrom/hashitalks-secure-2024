terraform {
  required_providers {
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }

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
      version = "1.1.15"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "2.3.4"
    }

    http = {
      source  = "hashicorp/http"
      version = "3.4.2"
    }

    local = {
      source  = "hashicorp/local"
      version = "2.5.1"
    }

    null = {
      source  = "hashicorp/null"
      version = "3.2.2"
    }

    random = {
      source  = "hashicorp/random"
      version = "3.6.1"
    }

    time = {
      source  = "hashicorp/time"
      version = "0.11.1"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "4.0.5"
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
