resource "aws_vpc" "gk-aws-vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    name = "gk-aws-vpc-terraform"
  }
}

resource "aws_subnet" "gk-aws-subnet" {
  vpc_id     = aws_vpc.gk-aws-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "gk-aws-subnet-terraform"
  }
}

resource "aws_internet_gateway" "gk-aws-ig" {
  vpc_id = aws_vpc.gk-aws-vpc.id

  tags = {
    Name = "gk-aws-ig-terraform"
  }
}

resource "aws_route_table" "gk-aws-rt" {
  vpc_id = aws_vpc.gk-aws-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gk-aws-ig.id
  }

  tags = {
    Name = "gk-aws-rt-terraform"
  }
}

resource "aws_route_table_association" "gk-aws-rta" {
  subnet_id      = aws_subnet.gk-aws-subnet.id
  route_table_id = aws_route_table.gk-aws-rt.id
}

resource "aws_security_group" "gk-aws-sg" {
  name        = "gk-aws-sg-terraform"
  description = "Allow access on port 22"
  vpc_id      = aws_vpc.gk-aws-vpc.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gk-aws-sg-terraform"
  }
}