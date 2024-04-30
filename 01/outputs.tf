output "aws_private_subnets" {
  description = "List of private subnets"
  value = [
    {
      id                = aws_subnet.private01.id
      availability_zone = aws_subnet.private01.availability_zone
      cidr_block        = aws_subnet.private01.cidr_block
    },
    {
      id                = aws_subnet.private02.id
      availability_zone = aws_subnet.private02.availability_zone
      cidr_block        = aws_subnet.private02.cidr_block
    },
    {
      id                = aws_subnet.private03.id
      availability_zone = aws_subnet.private03.availability_zone
      cidr_block        = aws_subnet.private03.cidr_block
    },
  ]
}

output "aws_public_subnets" {
  description = "List of public subnets"
  value = [
    {
      id                = aws_subnet.public01.id
      availability_zone = aws_subnet.public01.availability_zone
      cidr_block        = aws_subnet.public01.cidr_block
    },
    {
      id                = aws_subnet.public02.id
      availability_zone = aws_subnet.public02.availability_zone
      cidr_block        = aws_subnet.public02.cidr_block
    },
    {
      id                = aws_subnet.public03.id
      availability_zone = aws_subnet.public03.availability_zone
      cidr_block        = aws_subnet.public03.cidr_block
    },
  ]
}

output "aws_vpc" {
  description = "The AWS VPC resource"
  value = {
    id         = aws_vpc.this.id
    cidr_block = aws_vpc.this.cidr_block
  }
}

output "hcp_boundary_cluster_url" {
  description = "HCP Boundary cluster URL"
  value       = hcp_boundary_cluster.this.cluster_url
}

output "hcp_vault_cluster_private_url" {
  description = "HCP Vault private URL"
  value       = hcp_vault_cluster.this.vault_private_endpoint_url
}

output "hcp_vault_cluster_public_url" {
  description = "HCP Vault public URL"
  value       = hcp_vault_cluster.this.vault_public_endpoint_url
}
