data "aws_vpc" "this" {
  tags = {
    Name = "vpc-${var.aws_region}"
  }
}

data "aws_subnet" "public01" {
  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[0]}"
  }
}

data "aws_subnet" "public02" {
  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[1]}"
  }
}

data "aws_subnet" "public03" {
  tags = {
    Name = "subnet-public-${data.aws_availability_zones.available.names[2]}"
  }
}

data "aws_subnet" "private01" {
  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[0]}"
  }
}

data "aws_subnet" "private02" {
  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[1]}"
  }
}

data "aws_subnet" "private03" {
  tags = {
    Name = "subnet-private-${data.aws_availability_zones.available.names[2]}"
  }
}
