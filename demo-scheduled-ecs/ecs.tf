locals {
  container_definitions = [
    {
      "name" : var.task_name,
      "image" : "${data.aws_ecr_repository.existing.repository_url}:${var.image_tag}",
      "cpu" : var.task_cpu / 1024,
      "memoryReservation" : var.task_memory,
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-region" : data.aws_region.current.name,
          "awslogs-group" : var.task_name,
          "awslogs-stream-prefix" : var.task_name,
          "awslogs-create-group" : "true"
        }
      }
    }
  ]
}


resource "aws_ecs_cluster" "main" {
  name  = var.task_name
}

resource "aws_ecs_task_definition" "this" {
  family                   = var.task_name
  container_definitions    = jsonencode(local.container_definitions)
  task_role_arn            = var.task_role_arn
  execution_role_arn       = local.ecs_task_execution_role_arn
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "1024"
}
