provider "aws" {
  region = "eu-north-1"
}

data "aws_caller_identity" "me" {}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

########################
# CloudWatch
########################

resource "aws_cloudwatch_log_group" "ecs" {
  name = "/ecs/day9"
}

########################
# DynamoDB
########################

resource "aws_dynamodb_table" "notes" {
  name         = "day9-notes"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

########################
# ECS
########################

resource "aws_ecs_cluster" "main" {
  name = "day9-cluster"
}

########################
# IAM
########################

resource "aws_iam_role" "task" {
  name = "day9-task"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "ddb" {
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["dynamodb:*"]
      Resource = aws_dynamodb_table.notes.arn
    }]
  })
}

########################
# Security Groups
########################

resource "aws_security_group" "alb" {
  name   = "day9-alb"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "ecs" {
  name   = "day9-ecs"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port       = 5000
    to_port         = 5000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

########################
# Load Balancer
########################

resource "aws_lb" "alb" {
  name               = "day9-alb"
  load_balancer_type = "application"
  subnets            = data.aws_subnets.default.ids
  security_groups   = [aws_security_group.alb.id]
}

resource "aws_lb_target_group" "tg" {
  name     = "day9-tg"
  port     = 5000
  protocol = "HTTP"
  vpc_id  = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path = "/health"
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.alb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}

########################
# Task Definition
########################

resource "aws_ecs_task_definition" "app" {
  family                   = "day9"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512

  execution_role_arn = aws_iam_role.task.arn
  task_role_arn      = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name = "app"
      image = "${data.aws_caller_identity.me.account_id}.dkr.ecr.eu-north-1.amazonaws.com/day9-notes:latest"
      essential = true

      environment = [
        { name = "TABLE_NAME", value = aws_dynamodb_table.notes.name }
      ]

      portMappings = [{
        containerPort = 5000
        hostPort = 5000
      }]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group = aws_cloudwatch_log_group.ecs.name
          awslogs-region = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

########################
# Service
########################

resource "aws_ecs_service" "svc" {
  name            = "day9"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count  = 1
  launch_type    = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.tg.arn
    container_name   = "app"
    container_port   = 5000
  }

  depends_on = [aws_lb_listener.http]
}

########################
# Outputs
########################

output "alb_dns" {
  value = aws_lb.alb.dns_name
}