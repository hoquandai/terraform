================================================================
# ECS Fargate Dashboard
================================================================

- Document: https://docs.aws.amazon.com/AmazonECS/latest/userguide/cloudwatch-metrics.html
- Template: `templates/ecs_fargate_dashboard.tpl`

### Metrics
  - CPUUtilization { ClusterName, ServiceName }
  - MemoryUtilization { ClusterName, ServiceName }
