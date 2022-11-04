resource "aws_ecs_cluster" "cluster" {
  name = "sns-cluster"
}

resource "aws_ecs_task_definition" "task" {
  family                = var.name
  container_definitions = data.template_file.container_definitions.rendered
  execution_role_arn    = aws_iam_role.ecs_execution_role.arn

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
