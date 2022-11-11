resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "sns"
  }
}

resource "aws_subnet" "private1" {
  availability_zone = var.az_ids[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "private2" {
  availability_zone = var.az_ids[1]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
}

resource "aws_subnet" "private3" {
  availability_zone = var.az_ids[2]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
}

resource "aws_security_group" "opensearch" {
  name        = "${local.custom_name}-opensearch"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "tcp"
    cidr_blocks = [
      aws_vpc.vpc.cidr_block,
    ]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
