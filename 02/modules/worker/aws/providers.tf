terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }

    boundary = {
      source  = "hashicorp/boundary"
      version = "1.1.15"
    }
  }
}
