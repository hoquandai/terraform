terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.37"
    }
  }

  required_version = ">= 1.3"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "webserver" {
  ami                         = var.aws_ami
  instance_type               = var.instance_type
  key_name                    = aws_key_pair.webserver_keypair.key_name
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.security_groups.id]
  subnet_id                   = aws_subnet.subnet.id
  user_data                   = file("${var.bootstrap_script_path}")

  tags = {
    Name = "webserver"
  }
}
