variable "aws_region" {
  description = "AWS region name"
  type        = string

  validation {
    condition = contains([
      "ap-northeast-1",
      "ap-southeast-1",
      "ap-southeast-2",
      "eu-central-1",
      "eu-west-1",
      "eu-west-2",
      "ca-central-1",
      "us-east-1",
      "us-east-2",
      "us-west-2",
    ], var.aws_region)
    error_message = "HCP HVN requires you to use one of a few select regions"
  }
}

variable "aws_vpc_cidr_block" {
  description = "CIDR block for the AWS Virtual Private Cloud (VPC)"
  type        = string
  default     = "10.0.0.0/16"
}


variable "hcp_boundary_admin_password" {
  description = "Boundary initial admin password (username will be admin)"
  type        = string
  sensitive   = true
}

variable "hcp_virtual_network_cidr" {
  description = "CIDR block for the HashiCorp Virtual Network (HVN)"
  type        = string
  default     = "192.168.100.0/24"
}
