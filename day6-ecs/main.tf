provider "aws" {}

################
# IAM ROLE
################

resource "aws_iam_role" "ecs_task_role" {
  name = "ecs-task-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

################
# ECS CLUSTER
################

resource "aws_ecs_cluster" "main" {
  name = "day6-cluster"
}

################
# TASK DEFINITION
################

resource "aws_ecs_task_definition" "task" {
  family                   = "day6-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "awscli"
      image     = "amazon/aws-cli"
      essential = true
      command   = ["sleep", "3600"]
    }
  ])
}