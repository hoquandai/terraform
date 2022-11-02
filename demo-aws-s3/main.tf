terraform {
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

resource "aws_s3_bucket" "bucket" {
  bucket = "daiho-demo-aws-s3"
  policy = file("policy.json")

  tags = {
    Environment = "dev"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_object" "files" {
  for_each = fileset(var.website_root, "**")

  bucket       = aws_s3_bucket.bucket.id
  key          = each.key
  source       = "${var.website_root}/${each.key}"
  source_hash  = filemd5("${var.website_root}/${each.key}")
  acl          = "public-read"
  content_type = "text/html"
}

resource "aws_s3_bucket_website_configuration" "static_website" {
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}
