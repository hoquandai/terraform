variable "name" {
  description = "Application name"
  default     = "sns-cluster"
}

variable "image" {
  description = "Docker image to run in the ECS cluster"
  default     = "043525666653.dkr.ecr.us-east-1.amazonaws.com/sns:latest"
}

variable "cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "2048"
}

variable "logs_group" {
  description = "Logs group to provision"
  default     = "sns-log"
}

variable "service_names" {
  type = list(string)
  default = ["sns-cluster-service"]
}

variable "cluster_name" {
  type = string
  default = "sns-cluster"
}

variable "aws_region" {
  type = string
  default = "us-east-1"
}

variable "schedule_expression" {
  type = string
  default = "rate(5 minutes)"
}

variable "sns_topic_arn" {
  type = string
  default = "arn:aws:sns:us-east-1:043525666653:daiho"
}

variable "cron_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "999470467750.dkr.ecr.us-east-1.amazonaws.com/sns:latest"
}
