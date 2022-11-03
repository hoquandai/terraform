variable "name" {
  description = "Application name"
  default     = "sns-cluster"
}

variable "image" {
  description = "Docker image to run in the ECS cluster"
  default     = "public.ecr.aws/amazonlinux/amazonlinux:2022"
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
