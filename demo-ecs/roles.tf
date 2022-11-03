resource "aws_iam_role" "ecs_execution_role" {
  name               = var.name
  assume_role_policy = file("policies/ecs-task-execution-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "ecs_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
