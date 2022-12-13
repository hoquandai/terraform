resource "aws_kms_key" "ecs_exec" {
  description             = "ecs-exec"
  deletion_window_in_days = 7
}

resource "aws_kms_key" "ecs_exec_log" {
  description             = "ecs-exec-log"
  policy = data.aws_iam_policy_document.ecs_exec_log.json
  deletion_window_in_days = 7
}

resource "aws_cloudwatch_log_group" "ecs_exec" {
  name = "ecs-exec-log"
  kms_key_id = aws_kms_key.ecs_exec_log.arn
}

resource "aws_ecs_cluster" "cluster" {
  name = "sns-cluster"

  configuration {
    execute_command_configuration {
      kms_key_id = aws_kms_key.ecs_exec.arn
      logging    = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.ecs_exec.name
      }
    }
  }
}

resource "aws_ecs_task_definition" "task" {
  family                = var.name
  container_definitions = templatefile("templates/container_defination.tmpl", {
    name        = var.name
    image       = var.image
    cpu         = var.cpu
    memory      = var.memory
    logs_group  = var.logs_group
    logs_region = "us-east-1"
    command     = null
  })
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
}

resource "aws_ecs_task_definition" "cron" {
  family                = var.name
  container_definitions = templatefile("templates/container_defination.tmpl", {
    name        = var.name
    image       = var.cron_image
    cpu         = var.cpu
    memory      = var.memory
    logs_group  = var.logs_group
    logs_region = "us-east-1"
    command     = "echo 'Helloworld'"
  })
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn
  task_role_arn         = aws_iam_role.ecs_task_role.arn

  network_mode = "awsvpc"

  requires_compatibilities = ["FARGATE"]
  cpu                      = var.cpu
  memory                   = var.memory
}

resource "aws_ecs_service" "service" {
  name            = "${var.name}-service"
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.task.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  // required for task definitions that use the awsvpc network mode
  network_configuration {
    security_groups = [aws_security_group.sg.id]
    subnets         = [aws_subnet.private.id] // TODO: get from terraform remote state
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_group.id
    container_name   = var.name
    container_port   = 80
  }

  depends_on = [aws_alb_listener.front_end, aws_cloudwatch_log_group.log, aws_iam_role_policy_attachment.ecs_role_policy]
}
