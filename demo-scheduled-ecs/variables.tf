variable "task_name" {
  type = string
  default = "sns"
}

variable "expression" {
  type = string
  default = "rate(5 minutes)"
}
