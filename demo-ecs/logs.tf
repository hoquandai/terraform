resource "aws_cloudwatch_log_group" "log" {
  name = var.logs_group
  # retention_in_days = xxxxx (0)
  # kms_key_id = xxxxx // TODO: ARN of the KMS Key to use when encrypting log data.
}

resource "aws_cloudwatch_log_stream" "cb_log_stream" {
  name           = "${var.logs_group}-stream"
  log_group_name = aws_cloudwatch_log_group.log.name
}
