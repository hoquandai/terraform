resource "aws_cloudwatch_dashboard" "ecs" {
  dashboard_name = "ECS-Fargate"

  dashboard_body = templatefile("templates/ecs_fargate_dashboard.json.tpl", { 
    cluster_name = "sns-cluster",
    service_names = ["sns-cluster-0-service", "sns-cluster-1-service"],
    aws_region   = "us-east-1"
  })
}
