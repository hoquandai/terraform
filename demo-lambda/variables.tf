variable "create_function" {
  description = "Whether to create a new lambda function or not."
  type = bool
  default = true
}

variable "create_role" {
  description = "Whether to create a new lambda function role or not."
  type = bool
  default = true
}

variable "lambda_role_arn" {
  description = "Created Lambda role ARN."
  type = string
  default = null
}

variable "configuration" {
  description = "Function configuration with local package."
  type = object({
    filename = string, # path to the function Zip package within local system.
    function_name = string, # unique name for Lambda Function.
    handler = string, # function entrypoint
    runtime = string, # function's runtime
    architectures = list(string) # instruction set architecture
  })
}

variable "allowed_triggers" {
  description = "Triggers are allowed to access the Lambda function."
  type = map(any)
  default = {}
}

variable "environment_variables" {
  description = "Evironments to excute the Lambda function."
  type = map(any)
  default = {}
}

variable "dead_letter_target_arn" {
  description = "ARN of an SNS topic or SQS queue to notify when an invocation fails."
  type = string
  default = null
}

variable "attach_dead_letter_policy" {
  description = "Attach policy to Lambda's execution role to push message to Dead Letter Target."
  type = bool
  default = false
}

variable "log_group_arn" {
  description = "ARN of Cloudwatch Log Group to store log messages."
  type = string
  default = null
}

variable "attach_log_policy" {
  description = "Attach policy to Lambda's execution role to push to Cloudwatch log."
  type = bool
  default = false
}
