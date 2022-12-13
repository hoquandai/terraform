locals {
  task_name = "scheduled-${var.name}"
}

################################
### Cloudwatch Excution Role
################################

data "aws_iam_policy_document" "cloudwatch_assume_role" {
  statement {
    principals {
      type = "Service"
      identifiers = [
        "events.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
    actions = ["sts:AssumeRole"]
  }
}

data "aws_iam_policy_document" "cloudwatch" {

  statement {
    effect    = "Allow"
    actions   = ["ecs:RunTask"]
    resources = [aws_ecs_task_definition.cron.arn]
  }
  statement {
    effect  = "Allow"
    actions = ["iam:PassRole"]
    resources = [aws_iam_role.ecs_execution_role.arn, aws_iam_role.ecs_task_role.arn]
  }
}

resource "aws_iam_role" "cloudwatch_role" {
  name               = "${local.task_name}-cloudwatch-execution"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json

}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  role       = aws_iam_role.cloudwatch_role.name
  policy_arn = aws_iam_policy.cloudwatch.arn
}

resource "aws_iam_policy" "cloudwatch" {
  name   = "${local.task_name}-cloudwatch-execution"
  policy = data.aws_iam_policy_document.cloudwatch.json
}

################################
### End Cloudwatch Excution Role
################################

resource "aws_cloudwatch_event_rule" "run_ecs_task" {
  name                = local.task_name
  schedule_expression = var.schedule_expression
  is_enabled          = true
}

resource "aws_cloudwatch_event_target" "run_ecs_task" {
  rule      = aws_cloudwatch_event_rule.run_ecs_task.name
  target_id = local.task_name
  arn       = aws_ecs_cluster.cluster.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.cron.arn
    
    network_configuration {
      security_groups = [aws_security_group.sg.id]
      subnets         = [aws_subnet.private.id]
    }
  }
}

resource "aws_cloudwatch_event_rule" "ecs_task_failure" {
  name        = "${local.task_name}-alarm"
  is_enabled  = true
  description = "Watch for ${local.task_name} tasks that exit with non zero exit codes"

  event_pattern = templatefile("templates/ecs_task_failure.json.tpl", {
    cluster_arn         = aws_ecs_cluster.cluster.arn
    task_definition_arn = aws_ecs_task_definition.cron.arn
  })
}

resource "aws_cloudwatch_event_target" "ecs_task_failure" {
  rule  = aws_cloudwatch_event_rule.ecs_task_failure.name
  arn   = var.sns_topic_arn
  input = jsonencode({"message" : "Task ${local.task_name} failed."})
}

data "aws_iam_policy_document" "ecs_task_failure" {
  statement {
    actions   = ["SNS:Publish"]
    effect    = "Allow"
    resources = [var.sns_topic_arn]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
  }
}

resource "aws_sns_topic_policy" "ecs_task_failure" {
  arn    = var.sns_topic_arn
  policy = data.aws_iam_policy_document.ecs_task_failure.json
}
