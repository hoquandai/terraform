##########################################
# Assume Role
##########################################

resource "aws_iam_role" "lambda" {
  count = var.create_role ? 1 : 0

  name               = "iam_for_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

##########################################
# Cloudwatch Logs
##########################################

locals {
  attach_log = var.create_role && var.attach_log_policy
}

data "aws_iam_policy_document" "log" {
  count = local.attach_log ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    resources = [
      "${var.log_group_arn}:*"
    ]
  }
}

resource "aws_iam_policy" "log" {
  count = local.attach_log ? 1 : 0

  name   = "lamda-log-policy"
  policy = data.aws_iam_policy_document.log[0].json
}

resource "aws_iam_role_policy_attachment" "log" {
  count = local.attach_log ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.log[0].arn
}

##########################################
# Dead Letter Policies
##########################################

locals {
  attach_dead_letter = var.create_role && var.attach_dead_letter_policy
}

data "aws_iam_policy_document" "dead_letter" {
  count = local.attach_dead_letter ? 1 : 0

  statement {
    effect = "Allow"

    actions = [
      "sns:Publish",
      "sqs:SendMessage",
    ]

    resources = [
      var.dead_letter_target_arn
    ]
  }
}

resource "aws_iam_policy" "dead_letter" {
  count = local.attach_dead_letter ? 1 : 0

  name   = "lamda-dead-letter-policy"
  policy = data.aws_iam_policy_document.dead_letter[0].json
}

resource "aws_iam_role_policy_attachment" "dead_letter" {
  count = local.attach_dead_letter ? 1 : 0

  role       = aws_iam_role.lambda[0].name
  policy_arn = aws_iam_policy.dead_letter[0].arn
}
