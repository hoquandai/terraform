output "ecs_name" {
  description = "Name of ECS Service"
  value       = aws_ecs_service.service.name
}
