terraform {
  backend "remote" {
    organization = "DAIHO-ACG-Terraform-DemoS"
    workspaces {
      name = "Example-Workspace"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}

resource "aws_instance" "app_server" {
  ami           = "ami-0ab4d1e9cf9a1215a"
  instance_type = "t2.micro"

  tags = {
    Name = var.instance_name
  }
}
