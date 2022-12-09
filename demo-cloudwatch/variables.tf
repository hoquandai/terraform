##########################################ß
# ECS
# Doc: https://docs.aws.amazon.com/AmazonECS/latest/developerguide/cloudwatch-metrics.html
##########################################

variable "ecs_dashboards" {
  type = map(any)
  default = {
    clusters = [
      {
        name = "sns-cluster",
        services = ["api", "ecs"],
        metrics = {
          CPUReservation = {
            stat = "Average"
          },
          CPUUtilization = {
            stat = "Average"
          },
          MemoryReservation = {
            stat = "Average"
          },
          MemoryUtilization = {
            stat = "Average"
          }
        }
      }
    ]
  }
}
