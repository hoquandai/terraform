locals {
  custom_name = "${var.org_name}-${var.app_name}-${var.env}"
}

resource "aws_iam_service_linked_role" "main" {
  aws_service_name = "opensearchservice.amazonaws.com"
}

resource "aws_opensearch_domain" "main" {
  domain_name    = "${local.custom_name}-opensearch"
  engine_version = var.engine_version
  tags           = var.tags

  cluster_config {
    instance_type  = var.instance_type
    instance_count = var.instance_count > length(var.az_ids) ? var.instance_count : length(var.az_ids)

    zone_awareness_enabled = length(var.az_ids) > 1 ? true : false
    zone_awareness_config {
      availability_zone_count = length(var.az_ids)
    }

    dedicated_master_enabled = var.dedicated_master_count > 0 ? true : false
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type

    warm_enabled = var.warm_enabled
    warm_count   = var.warm_count
  }

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  encrypt_at_rest {
    enabled = true
  }

  vpc_options {
    subnet_ids         = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id]
    security_group_ids = [aws_security_group.opensearch.id]
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.opensearch.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  depends_on = [aws_iam_service_linked_role.main]
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name = aws_opensearch_domain.main.domain_name

  access_policies = <<POLICIES
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "es:*",
      "Principal": "*",
      "Effect": "Allow",
      "Resource": "${aws_opensearch_domain.main.arn}/*"
    }
  ]
}
POLICIES
}
