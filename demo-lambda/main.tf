resource "aws_lambda_function" "main" {
  count         = var.create_function ? 1 : 0

  filename      = var.configuration.filename
  function_name = var.configuration.function_name
  role          = var.create_role ? aws_iam_role.lambda[0].arn : var.lambda_role_arn
  handler       = var.configuration.handler

  source_code_hash = filebase64sha256(var.configuration.filename)

  runtime       = var.configuration.runtime
  architectures = var.configuration.architectures

  dynamic "environment" {
    for_each = length(keys(var.environment_variables)) == 0 ? [] : [1]
    content {
      variables = var.environment_variables
    }
  }

  dynamic "dead_letter_config" {
    for_each = var.dead_letter_target_arn == null ? [] : [1]
    content {
      target_arn = var.dead_letter_target_arn
    }
  }
}

resource "aws_lambda_permission" "invoke" {
  for_each = { for k, v in var.allowed_triggers : k => v if length(keys(var.allowed_triggers)) > 0 }

  statement_id = each.key
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.main[0].function_name
  principal     = try(each.value.principal, null)
  source_arn    = try(each.value.source_arn, null)
}
