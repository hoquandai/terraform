output "arn" {
  description = "Lambda function ARN"
  value = var.create_function ? aws_lambda_function.main[0].arn : null
}
