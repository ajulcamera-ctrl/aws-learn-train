#!/bin/bash
set -e

echo "Generating Day12 - Private Subnets + Multi NAT + Real Network Test"

mkdir -p terraform

########################################
# main.tf
########################################
cat > terraform/main.tf <<'EOF'
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-north-1"
}

############################
# VPC
############################

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  tags = { Name = "day12-vpc" }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

data "aws_availability_zones" "az" {}

############################
# Public Subnets
############################

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.az.names[0]
  map_public_ip_on_launch = true
  tags = { Name = "day12-public-a" }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = data.aws_availability_zones.az.names[1]
  map_public_ip_on_launch = true
  tags = { Name = "day12-public-b" }
}

############################
# Private Subnets
############################

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.10.0/24"
  availability_zone = data.aws_availability_zones.az.names[0]
  tags = { Name = "day12-private-a" }
}

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.20.0/24"
  availability_zone = data.aws_availability_zones.az.names[1]
  tags = { Name = "day12-private-b" }
}

############################
# Route Tables
############################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public.id
}

############################
# NAT Gateways (Multi AZ)
############################

resource "aws_eip" "nat_a" { domain = "vpc" }
resource "aws_eip" "nat_b" { domain = "vpc" }

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a.id
  subnet_id     = aws_subnet.public_a.id
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b.id
  subnet_id     = aws_subnet.public_b.id
}

resource "aws_route_table" "private_a" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_a.id
  }
}

resource "aws_route_table" "private_b" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_b.id
  }
}

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_a.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_b.id
}

############################
# ECS Cluster
############################

resource "aws_ecs_cluster" "main" {
  name = "day12-cluster"
}

############################
# CloudWatch Logs
############################

resource "aws_cloudwatch_log_group" "test" {
  name              = "/day12/test"
  retention_in_days = 1
}

############################
# Security Group
############################

resource "aws_security_group" "ecs" {
  vpc_id = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

############################
# Task Execution Role
############################

resource "aws_iam_role" "ecs_task_execution" {
  name = "day12-ecs-exec-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_exec_attach" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

############################
# Test Task Definition
############################

resource "aws_ecs_task_definition" "test" {
  family                   = "day12-test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn

  container_definitions = jsonencode([
    {
      name  = "tester"
      image = "alpine"
      command = ["sh", "-c", "apk add curl && curl -s http://example.com && sleep 60"]
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/day12/test"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "test" {
  name            = "day12-test-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.test.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_a.id, aws_subnet.private_b.id]
    security_groups  = [aws_security_group.ecs.id]
    assign_public_ip = false
  }
}
EOF

########################################
# deploy.sh
########################################
cat > terraform/deploy.sh <<'EOF'
#!/bin/bash
cd terraform
terraform init
terraform apply -auto-approve
EOF

########################################
# test.sh
########################################
cat > terraform/test.sh <<'EOF'
#!/bin/bash
echo "Waiting 60 seconds for ECS task to run..."
sleep 60

echo "Fetching CloudWatch logs..."

aws logs filter-log-events \
  --log-group-name /day12/test \
  --region eu-north-1 \
  --query 'events[*].message' \
  --output text
EOF

########################################
# destroy.sh
########################################
cat > terraform/destroy.sh <<'EOF'
#!/bin/bash
cd terraform
terraform destroy -auto-approve
EOF

########################################
# verify.sh
########################################
cat > terraform/verify.sh <<'EOF'
#!/bin/bash
echo "Checking for remaining NAT Gateways..."
aws ec2 describe-nat-gateways \
  --region eu-north-1 \
  --query 'NatGateways[?State!=`deleted`]'
EOF

chmod +x terraform/*.sh
echo "Day12 generated."