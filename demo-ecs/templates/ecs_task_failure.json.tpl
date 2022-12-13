{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "lastStatus": [
      "STOPPED"
    ],
    "stopCode": [
      { "exists": true  }
    ],
    "clusterArn": ["${cluster_arn}"],
    "taskDefinitionArn": ["${task_definition_arn}"]
  }
}
