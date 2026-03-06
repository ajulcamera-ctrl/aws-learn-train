provider "aws" {
  region = "eu-north-1"
}

# CloudWatch log group
resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/day7"
}

# ECS cluster
resource "aws_ecs_cluster" "this" {
  name = "day7-cluster"
}

# ECS Task IAM role
resource "aws_iam_role" "task" {
  name = "day7-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

# Attach CloudWatch policy
resource "aws_iam_role_policy_attachment" "logs" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "app" {
  family                   = "day7"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.task.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([{
    name  = "app"
    image = "223597091881.dkr.ecr.eu-north-1.amazonaws.com/day7-notes:latest"
    essential = true
    portMappings = [{
      containerPort = 5000
    }]
    logConfiguration = {
      logDriver = "awslogs"
      options = {
        awslogs-group         = aws_cloudwatch_log_group.ecs.name
        awslogs-region        = "eu-north-1"
        awslogs-stream-prefix = "ecs"
      }
    }
  }])

  
}

# ECS Service
resource "aws_ecs_service" "svc" {
  name            = "day7"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  enable_execute_command = true

  network_configuration {
    assign_public_ip = true
    subnets          = data.aws_subnets.default.ids
  }
}

# Default VPC and subnets
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}
