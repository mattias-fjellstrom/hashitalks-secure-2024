data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "this" {
  cidr_block           = var.aws_vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "vpc-${var.aws_region}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "igw-${var.aws_region}"
  }
}

resource "aws_eip" "nat_gateway" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.this]
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat_gateway.id
  subnet_id     = aws_subnet.public01.id

  tags = {
    Name = "nat-gw-${data.aws_availability_zones.available.names[0]}"
  }

  depends_on = [aws_internet_gateway.this]
}

# PUBLIC SUBNETS ---------------------------------------------------------------
resource "aws_subnet" "public01" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 0)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_subnet" "public02" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 1)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[1]}"
  }
}

resource "aws_subnet" "public03" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 2)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[2]}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "rt-public-${var.aws_region}"
  }
}

resource "aws_route_table_association" "public01" {
  subnet_id      = aws_subnet.public01.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public02" {
  subnet_id      = aws_subnet.public02.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public03" {
  subnet_id      = aws_subnet.public03.id
  route_table_id = aws_route_table.public.id
}

# PRIVATE SUBNETS --------------------------------------------------------------
resource "aws_subnet" "private01" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 128)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[0]

  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[0]}"
  }
}

resource "aws_subnet" "private02" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 129)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[1]

  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[1]}"
  }
}

resource "aws_subnet" "private03" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = cidrsubnet(var.aws_vpc_cidr_block, 8, 130)
  map_public_ip_on_launch = false
  availability_zone       = data.aws_availability_zones.available.names[2]

  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[2]}"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.this.id
  }

  route {
    cidr_block                = var.hcp_virtual_network_cidr
    vpc_peering_connection_id = hcp_aws_network_peering.this.provider_peering_id
  }

  tags = {
    Name = "rt-private-${var.aws_region}"
  }
}

resource "aws_route_table_association" "private01" {
  subnet_id      = aws_subnet.private01.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private02" {
  subnet_id      = aws_subnet.private02.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private03" {
  subnet_id      = aws_subnet.private03.id
  route_table_id = aws_route_table.private.id
}
