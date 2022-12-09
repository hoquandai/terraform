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

resource "aws_s3_bucket" "s3" {
  bucket = "daiho-demo-aws-s3"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  tags = {
    Environment = "dev"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.s3.id
  acl    = "private"
}

resource "aws_s3_bucket_object" "files" {
  for_each = fileset(var.website_root, "**")

  bucket       = aws_s3_bucket.s3.id
  key          = each.key
  source       = "${var.website_root}/${each.key}"
  source_hash  = filemd5("${var.website_root}/${each.key}")
  acl          = "private"
  content_type = "text/html"
}

locals {
  s3_origin_id = "DaiHo1508S3Origin"
  authen_code = base64encode("${var.cloudfront.username}:${var.cloudfront.password}")
}

resource "aws_acm_certificate" "cert" {
  domain_name       = "daiho150898.com"
  validation_method = "DNS"

  tags = {
    Environment = "dev"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_cloudfront_function" "basic_auth" {
  name    = "basic_auth"
  runtime = "cloudfront-js-1.0"
  comment = "Basic Auth"
  publish = true
  code    =  templatefile("handler.js.tpl", {
    token = local.authen_code
  })
}

resource "aws_cloudfront_distribution" "cloudfront" {
  enabled = true
  # is_ipv6_enabled = true
  # price_class = "PriceClass_All"
  # http_version = "http2"

  default_root_object = "index.html"

  origin {
    domain_name = aws_s3_bucket.s3.bucket_regional_domain_name
    origin_id = local.s3_origin_id

    custom_origin_config {
      http_port = 80
      https_port = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols = [
        "TLSv1", "TLSv1.1", "TLSv1.2"
      ]
    }
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "OPTIONS"]
    cached_methods = ["GET", "HEAD"]
    compress = true
    target_origin_id = local.s3_origin_id
    viewer_protocol_policy = "redirect-to-https"

    default_ttl = 0
    min_ttl = 0
    max_ttl = 0

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    function_association {
      event_type = "viewer-request"
      function_arn = aws_cloudfront_function.basic_auth.arn
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

data "aws_iam_policy_document" "s3_policy" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.s3.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "s3" {
  bucket = aws_s3_bucket.s3.id
  policy = data.aws_iam_policy_document.s3_policy.json
}

resource "aws_s3_bucket_public_access_block" "s3" {
  bucket = aws_s3_bucket.s3.id

  block_public_acls       = true
  block_public_policy     = true
  //ignore_public_acls      = true
  //restrict_public_buckets = true
}
