variable "app_name" {
  description = "The name of the application."
  type        = string
  default     = "sns"
}

variable "org_name" {
  description = "The name of the organization."
  type        = string
  default     = "daiho"
}

variable "env" {
  description = "The environment to run the application."
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Tag names for OpenSearch service."
  default = {
    name = "OpenSearch"
  }
}

variable "allow_security_groups" {
  description = "Allowed SecurityGroup IDs."
  type        = list(string)
  default     = []
}

variable "subnet_db_ids" {
  description = "Common private subnets for DB connections."
  type        = list(string)
  default     = []
}

# variable vpc_id {
#   description = "Main VPC ID."
#   type = string
# }

variable "az_ids" {
  description = "Availability zone IDS for data nodes."
  type        = list(string)
  default = [
    "us-east-1a",
    "us-east-1b"
  ]
}

variable "ebs_volume_size" {
  description = "Size of EBS volumes attached to data nodes (in GiB)."
  type        = number
  default     = 10
}

variable "ebs_volume_type" {
  description = "Type of EBS volumes attached to data nodes."
  type        = string
  default     = "gp2"
}

variable "dedicated_master_count" {
  description = "Number of dedicated main nodes in the cluster."
  type        = number
  default     = 0
}

variable "dedicated_master_type" {
  description = "Instance type of the dedicated main nodes in the cluster"
  type        = string
  default     = "m5.large.search"
}

variable "engine_version" {
  description = "OpenSearch engine version."
  type        = string
  default     = "OpenSearch_1.3"
}

variable "instance_type" {
  description = "OpenSearch instance type."
  type        = string
  default     = "t3.medium.search"
}

variable "instance_count" {
  description = "OpenSearch instance count."
  type        = number
  default     = 1
}

variable "master_user_name" {
  description = "OpenSearch Main user's username."
  type        = string
  default     = "master"
}

variable "master_user_password" {
  description = "OpenSearch Main user's password."
  type        = string
  default     = "Master_1_2_3"
}

locals {
  custom_name = "${var.org_name}-${var.app_name}-${var.env}"
}

data "aws_iam_policy_document" "access_policies" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions = [
      "es:ESHttp*"
    ]
    resources = [
      "${aws_opensearch_domain.main.arn}/*"
    ]
  }
}

data "aws_iam_policy_document" "opensearch_logs" {
  statement {
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["es.amazonaws.com"]
    }
    actions = [
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
      "logs:CreateLogStream",
    ]
    resources = [
      "arn:aws:logs:*"
    ]
  }
}

resource "aws_cloudwatch_log_group" "opensearch" {
  name              = "/opensearch/${local.custom_name}"
  retention_in_days = 365
}

resource "aws_cloudwatch_log_resource_policy" "opensearch" {
  policy_name     = "opensearch-${local.custom_name}"
  policy_document = data.aws_iam_policy_document.opensearch_logs.json
}

resource "aws_subnet" "opensearch" {
  availability_zone = data.aws_availability_zones.available.names[1]
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
}

resource "aws_security_group" "opensearch" {
  name        = "${local.custom_name}-opensearch"
  description = "Managed by Terraform"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# resource "aws_iam_service_linked_role" "main" {
#   aws_service_name = "opensearchservice.amazonaws.com"
# }

resource "aws_opensearch_domain" "main" {
  domain_name    = "${local.custom_name}-opensearch"
  engine_version = var.engine_version
  tags           = var.tags

  cluster_config {
    instance_type  = var.instance_type
    instance_count = 1

    zone_awareness_enabled = false

    dedicated_master_enabled = var.dedicated_master_count > 0 ? true : false
    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_type    = var.dedicated_master_type
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    anonymous_auth_enabled         = false
    master_user_options {
      master_user_name     = var.master_user_name
      master_user_password = var.master_user_password
    }
  }

  node_to_node_encryption {
    enabled = true
  }

  domain_endpoint_options {
    enforce_https       = true
    tls_security_policy = "Policy-Min-TLS-1-2-2019-07"
  }

  encrypt_at_rest {
    enabled = true
  }

  ebs_options {
    ebs_enabled = var.ebs_volume_size > 0 ? true : false
    volume_size = var.ebs_volume_size
    volume_type = var.ebs_volume_type
  }

  vpc_options {
    subnet_ids         = [aws_subnet.opensearch.id]
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

  # depends_on = [aws_iam_service_linked_role.main]
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name = aws_opensearch_domain.main.domain_name

  access_policies = data.aws_iam_policy_document.access_policies.json
}
