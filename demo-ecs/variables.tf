variable "name" {
  description = "Application name"
  default     = "sns-cluster"
}

variable "image" {
  description = "Docker image to run in the ECS cluster"
  default     = "598377268313.dkr.ecr.us-east-1.amazonaws.com/sns:latest"
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
