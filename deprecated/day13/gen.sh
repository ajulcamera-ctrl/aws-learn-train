#!/bin/bash

set -e

echo "Generating Day 13 project..."

mkdir -p terraform

########################################
# main.tf
########################################

cat > terraform/main.tf <<'EOF'
provider "aws" {
  region = var.region
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

########################################
# DynamoDB
########################################

resource "aws_dynamodb_table" "demo" {
  name         = var.table_name
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }
}

########################################
# IAM Role for ECS Task
########################################

resource "aws_iam_role" "ecs_task_role" {
  name = "day13-ecs-task-role"

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

resource "aws_iam_policy" "dynamodb_policy" {
  name = "day13-dynamodb-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.demo.arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.dynamodb_policy.arn
}

########################################
# ECS Cluster
########################################

resource "aws_ecs_cluster" "cluster" {
  name = "day13-cluster"
}

########################################
# ECS Task Definition (IAM Test)
########################################

resource "aws_ecs_task_definition" "iam_test" {
  family                   = "day13-iam-test"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "tester"
      image     = "amazon/aws-cli"
      essential = true
      command = [
        "sh",
        "-c",
        "aws dynamodb put-item --table-name ${var.table_name} --item '{\"id\":{\"S\":\"1\"}}' --region ${var.region} && \
         aws dynamodb scan --table-name ${var.table_name} --region ${var.region} && \
         aws dynamodb delete-table --table-name ${var.table_name} --region ${var.region} && exit 1 || exit 0"
      ]
    }
  ])
}
EOF

########################################
# variables.tf
########################################

cat > terraform/variables.tf <<'EOF'
variable "region" {
  default = "eu-west-2"
}

variable "table_name" {
  default = "day13-demo-table"
}
EOF

########################################
# deploy.sh
########################################

cat > deploy.sh <<'EOF'
#!/bin/bash
set -e
cd terraform
terraform init
terraform apply -auto-approve
cd ..
echo "Deploy complete."
EOF

chmod +x deploy.sh

########################################
# destroy.sh
########################################

cat > destroy.sh <<'EOF'
#!/bin/bash
set -e
cd terraform
terraform destroy -auto-approve
cd ..
echo "Destroy complete."
EOF

chmod +x destroy.sh

########################################
# test.sh
########################################

cat > test.sh <<'EOF'
#!/bin/bash

CLUSTER="day13-cluster"
TASK="day13-iam-test"

SUBNETS=$(aws ec2 describe-subnets \
  --query "Subnets[?DefaultForAz==\`true\`].SubnetId" \
  --output text | tr '\t' ',')

echo "Running IAM test task..."

TASK_ARN=$(aws ecs run-task \
  --cluster $CLUSTER \
  --launch-type FARGATE \
  --task-definition $TASK \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],assignPublicIp=ENABLED}" \
  --query "tasks[0].taskArn" \
  --output text)

echo "Waiting for task to stop..."
aws ecs wait tasks-stopped --cluster $CLUSTER --tasks $TASK_ARN

EXIT_CODE=$(aws ecs describe-tasks \
  --cluster $CLUSTER \
  --tasks $TASK_ARN \
  --query "tasks[0].containers[0].exitCode" \
  --output text)

if [ "$EXIT_CODE" = "0" ]; then
  echo "PASS: IAM least privilege enforced."
else
  echo "FAIL: DeleteTable permission was allowed!"
  exit 1
fi
EOF

chmod +x test.sh

########################################
# verify.sh
########################################

cat > verify.sh <<'EOF'
#!/bin/bash

echo "Checking resources..."

aws dynamodb list-tables | grep day13-demo-table && echo "Table exists"
aws ecs list-clusters | grep day13-cluster && echo "Cluster exists"

echo "Verify complete."
EOF

chmod +x verify.sh

echo "Day 13 files generated successfully."