// Cloudwatch trigger
// ------------------
resource "aws_cloudwatch_event_rule" "ecs_scheduled_task" {
  name                = var.task_name
  schedule_expression = var.expression
}

// Failure notification configuration (using Cloudwatch)
// -----------------------------------------------------
// We create an event rule that sends a message to an SNS Topic every time the task fails with a non-0 error code

resource "aws_cloudwatch_event_target" "ecs_scheduled_task" {
  rule      = aws_cloudwatch_event_rule.ecs_scheduled_task.name
  target_id = var.task_name
  arn       = aws_ecs_cluster.main.arn
  role_arn  = aws_iam_role.cloudwatch_role.arn

  ecs_target {
    launch_type         = "FARGATE"
    platform_version    = "LATEST"
    task_count          = 1
    task_definition_arn = aws_ecs_task_definition.this.arn

    network_configuration {
      subnets = var.subnet_ids
    }
  }
}

resource "aws_cloudwatch_event_rule" "task_failure" {
  name        = "${var.task_name}_task_failure"
  description = "Watch for ${var.task_name} tasks that exit with non zero exit codes"

  event_pattern = <<EOF
  {
    "source": [
      "aws.ecs"
    ],
    "detail-type": [
      "ECS Task State Change"
    ],
    "detail": {
      "lastStatus": [
        "STOPPED"
      ],
      "stoppedReason": [
        "Essential container in task exited"
      ],
      "containers": {
        "exitCode": [
          {"anything-but": 0}
        ]
      },
      "clusterArn": ["${aws_ecs_cluster.main.arn}"],
      "taskDefinitionArn": ["${aws_ecs_task_definition.this.arn}"]
    }
  }
  EOF
}
