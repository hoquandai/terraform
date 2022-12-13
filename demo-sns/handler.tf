resource "aws_sqs_queue" "dead_letter" {
  name = "lamda-dead-letter-queue"
}

resource "aws_cloudwatch_log_group" "sns_lambda" {
  name = "/aws/lambda/post_slack_message"
  retention_in_days = 90
}

module "slack_lambda" {
  source = "../demo-lambda"

  configuration = {
    filename = "functions/scheduled_ecs.rb.zip",
    function_name = "post_slack_message",
    handler = "scheduled_ecs.lambda_handler"
    runtime = "ruby2.7",
    architectures = ["x86_64"]
  }

  environment_variables = {
    ENVIRONMENT = "dev"
    SLACK_WEBHOOK_URL = "https://hooks.slack.com/services/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"
  }

  allowed_triggers = {
    AllowExecutionFromSNS = {
      principal  = "sns.amazonaws.com"
      source_arn = aws_sns_topic.main.arn
    }
  }

  dead_letter_target_arn = aws_sqs_queue.dead_letter.arn
  attach_dead_letter_policy = true

  log_group_arn = aws_cloudwatch_log_group.sns_lambda.arn
  attach_log_policy = true
}

