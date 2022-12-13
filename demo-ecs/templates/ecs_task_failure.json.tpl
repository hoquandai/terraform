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
    "stoppedReason": [
      "Essential container in task exited"
    ],
    "containers": {
      "exitCode": [
        1
      ]
    },
    "clusterArn": ["${cluster_arn}"],
    "taskDefinitionArn": ["${task_definition_arn}"]
  }
}
