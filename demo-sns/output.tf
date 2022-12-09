output "sns_topic_arn" {
  value = aws_sns_topic.main.arn
}

output "sns_topic_owner" {
  value = aws_sns_topic.main.owner
}
