resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "SNS"
  }
}

resource "aws_subnet" "primary" {
  availability_zone = var.az_ids[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name = "SNS-DBSubnet-Primary"
  }
}

resource "aws_subnet" "secondary" {
  availability_zone = var.az_ids[1]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name = "SNS-DBSubnet-Secondary"
  }
}

resource "aws_security_group" "opensearch" {
  name        = "${local.custom_name}-opensearch"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
