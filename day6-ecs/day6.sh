#!/bin/bash
set -e

echo "== Terraform init =="
terraform init

echo "== Terraform apply =="
terraform apply -auto-approve

echo "== Fetch subnet =="
SUBNET=$(aws ec2 describe-subnets --query 'Subnets[0].SubnetId' --output text)
echo "Using subnet: $SUBNET"

echo "== Run ECS task =="
aws ecs run-task \
  --cluster day6-cluster \
  --launch-type FARGATE \
  --task-definition day6-task \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET],assignPublicIp=ENABLED}"

echo ""
echo "Task started."
echo "Run this next (manually):"
echo ""
echo "aws ecs list-tasks --cluster day6-cluster"
echo ""
echo "Then:"
echo ""
echo "aws ecs execute-command --cluster day6-cluster --task TASK_ID --container awscli --interactive --command /bin/sh"
echo ""