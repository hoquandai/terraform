resource "aws_vpc" "vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  instance_tenancy     = "default"

  tags = {
    Name = "sns"
  }
}

resource "aws_subnet" "private" {
  availability_zone = data.aws_availability_zones.available.names[0]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
}

resource "aws_subnet" "public" {
  cidr_block              = "10.0.0.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public2" {
  cidr_block              = cidrsubnet(aws_vpc.vpc.cidr_block, 8, 3)
  availability_zone       = data.aws_availability_zones.available.names[1]
  vpc_id                  = aws_vpc.vpc.id
  map_public_ip_on_launch = true
}

# internet gateway for the public subnet
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id
}

# route the public subnet traffic through the IGW
resource "aws_route" "internet_access" {
  route_table_id         = aws_vpc.vpc.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gateway.id
}

# create an elasticIP for private subnet to get internet connectivity
resource "aws_eip" "eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.gateway]
}

# place a NAT gateway with an elasticIP in public subnet
resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.public.id
  allocation_id = aws_eip.eip.id
}

# create a new route table for the private subnets, make it route non-local traffic through the NAT gateway to the internet
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

# associate the newly created route tables to the private subnets (so they don't default to the main route table)
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.vpc.id
  service_name      = "com.amazonaws.us-east-1.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.private.id]
  # policy = file("policies/ecr_s3_policy.json")
}

resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.us-east-1.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.sg.id]
  subnet_ids          = [aws_subnet.private.id]
}

resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg.id]
  subnet_ids          = [aws_subnet.private.id]
}

resource "aws_vpc_endpoint" "cloudwatch-endpoint" {
  vpc_id              = aws_vpc.vpc.id
  service_name        = "com.amazonaws.us-east-1.monitoring"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  security_group_ids  = [aws_security_group.sg.id]
  subnet_ids          = [aws_subnet.private.id]
  policy              = file("policies/cloudwatch_policy.json")
}

resource "aws_security_group" "alb_sg" {
  name        = "alb_traffic"
  description = "ALB security group"
  vpc_id      = aws_vpc.vpc.id

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
}

resource "aws_security_group" "sg" {
  name        = "allow_traffic"
  description = "ECS traffics"
  vpc_id      = aws_vpc.vpc.id

  # TCP/443
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ALB access
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
