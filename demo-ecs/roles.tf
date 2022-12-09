resource "aws_iam_role" "ecs_execution_role" {
  name               = var.name
  assume_role_policy = file("policies/ecs-task-execution-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "ecs_task_role" {
  assume_role_policy = file("policies/ecs-task-execution-role-policy.json")
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    aws_iam_policy.ecs_task_cloudwatch.arn,
    aws_iam_policy.ecs_task_kms.arn
  ]
}

resource "aws_iam_policy" "ecs_task_cloudwatch" {
  name = "ecs-task-cloudwatch"
  policy = data.aws_iam_policy_document.ecs_task_cloudwatch.json
}

resource "aws_iam_policy" "ecs_task_kms" {
  name = "ecs-task-kms"
  policy = data.aws_iam_policy_document.ecs_task_kms.json
}

data "aws_iam_policy_document" "ecs_task_cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:DescribeLogGroups"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]
    resources = [
      "${aws_cloudwatch_log_group.ecs_exec.arn}:*"
    ]
  }
}

data "aws_iam_policy_document" "ecs_task_kms" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt"
    ]
    resources = [
      aws_kms_key.ecs_exec.arn
    ]
  }
}

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_iam_policy_document" "ecs_exec_log" {
  policy_id = "key-policy-cloudwatch"

  statement {
    sid = "Enable IAM User Permissions"
    actions = [
      "kms:*",
    ]
    effect = "Allow"
    principals {
      type = "AWS"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }
    resources = ["*"]
  }
  statement {
    sid = "AllowCloudWatchLogs"
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]
    effect = "Allow"
    principals {
      type = "Service"
      identifiers = [
        "logs.${data.aws_region.current.name}.amazonaws.com"
      ]
    }
    resources = ["*"]
  }
}
