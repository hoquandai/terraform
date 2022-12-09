output "ecs_name" {
  description = "Name of ECS Service"
  value       = aws_ecs_service.service.*.name
}

output "alb_hostname" {
  value = aws_alb.alb.dns_name
}
