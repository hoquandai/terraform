resource "aws_key_pair" "webserver_keypair" {
  key_name   = "webserver_keypair"
  public_key = file("${var.public_key_path}")
}

resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = "true"
  enable_dns_hostnames = "true"
  instance_tenancy     = "default"

  tags = {
    Name = "DaiHo VPC"
  }
}

resource "aws_subnet" "subnet" {
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
}

// VPC require an internet gateway to communicate over the internet.
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

// route table for VPC.
resource "aws_route_table" "route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"                      // associated subnet can reach everywhere
    gateway_id = aws_internet_gateway.gateway.id  // uses this IGW to reach internet
  }
}

// associate the route table with the public subnet.
resource "aws_route_table_association" "route_table_subnet" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.route_table.id
}

resource "aws_security_group" "security_groups" {
  name        = "allow_ports"
  description = "Allow TCP/22 and TCP/80"
  vpc_id      = aws_vpc.vpc.id

  #ssh access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access
  ingress {
    from_port   = 80
    to_port     = 80
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
    Name = "Allow SSH and HTTP"
  }
}
