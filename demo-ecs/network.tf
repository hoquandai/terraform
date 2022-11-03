resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "sns"
  }
}

resource "aws_subnet" "private_subnet" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_security_group" "sg" {
  name        = "allow_traffic"
  description = "Allow outbound"
  vpc_id      = aws_vpc.vpc.id

  # TCP/443
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
