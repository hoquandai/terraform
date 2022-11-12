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
