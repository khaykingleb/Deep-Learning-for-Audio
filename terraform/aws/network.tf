resource "aws_vpc" "this" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge({ name = "DLA-VPC" }, local.tags)
}

resource "aws_subnet" "this" {
  cidr_block        = cidrsubnet(aws_vpc.this.cidr_block, 3, 1)
  vpc_id            = aws_vpc.this.id
  availability_zone = local.availability_zone
}

resource "aws_security_group" "this" {
  vpc_id = aws_vpc.this.id

  ingress {
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

  tags = merge({ name = "DLA-SG" }, local.tags)
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id
  tags   = merge({ name = "DLA-IG" }, local.tags)
}

resource "aws_route_table" "this" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = merge({ name = "DLA-VPC" }, local.tags)
}

resource "aws_route_table_association" "subnet_association" {
  subnet_id      = aws_subnet.this.id
  route_table_id = aws_route_table.this.id
}
