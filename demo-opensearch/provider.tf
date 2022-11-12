terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.3"
    }
  }

  # backend "s3" {} // TODO
  required_version = ">= 1.3"
}

provider "aws" {
  profile = "default"
  region  = "us-east-1"
}
