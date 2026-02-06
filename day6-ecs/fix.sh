#!/bin/bash
set -e

echo "Finding default subnet..."
SUBNET=$(aws ec2 describe-subnets \
  --filters Name=default-for-az,Values=true \
  --query 'Subnets[0].SubnetId' \
  --output text)

echo "Subnet: $SUBNET"

echo "Finding default security group..."
SG=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=default \
  --query 'SecurityGroups[0].GroupId' \
  --output text)

echo "Security group: $SG"

echo "Running ECS task..."

aws ecs run-task \
  --cluster day6-cluster \
  --launch-type FARGATE \
  --task-definition day6-task \
  --network-configuration "awsvpcConfiguration={subnets=[$SUBNET],securityGroups=[$SG],assignPublicIp=ENABLED}"

echo ""
echo "Task started."
echo ""
echo "Next run:"
echo "aws ecs list-tasks --cluster day6-cluster"