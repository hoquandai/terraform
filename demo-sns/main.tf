resource "aws_sns_topic" "main" {
  name = "daiho"
}

resource "aws_sns_topic_policy" "main" {
  arn    = aws_sns_topic.main.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect = "Allow"

    actions = [
      "SNS:Publish",
      "SNS:RemovePermission",
      "SNS:SetTopicAttributes",
      "SNS:DeleteTopic",
      "SNS:ListSubscriptionsByTopic",
      "SNS:GetTopicAttributes",
      "SNS:AddPermission",
      "SNS:Subscribe"
    ]

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [aws_sns_topic.main.arn]
  }
}

resource "aws_sns_topic_subscription" "post_message" {
  topic_arn = aws_sns_topic.main.arn
  protocol  = "lambda"
  endpoint  = module.slack_lambda.arn

  depends_on = [aws_sns_topic.main, module.slack_lambda]
}