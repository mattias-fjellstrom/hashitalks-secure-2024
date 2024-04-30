terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.42.0"
    }

    hcp = {
      source  = "hashicorp/hcp"
      version = "0.83.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

provider "hcp" {}
