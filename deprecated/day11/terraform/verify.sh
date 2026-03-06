#!/bin/bash

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="tfstate-$ACCOUNT_ID-$REGION"

echo "Verifying Day 11 cleanup..."
echo "----------------------------------"

check() {
  if [ -z "$1" ]; then
    echo "✓ $2: NOT FOUND"
  else
    echo "✗ $2: STILL EXISTS"
  fi
}

# ECS Cluster
ECS_CLUSTER=$(aws ecs describe-clusters \
  --clusters day11-cluster \
  --region $REGION \
  --query "clusters[?status=='ACTIVE'].clusterName" \
  --output text 2>/dev/null)

check "$ECS_CLUSTER" "ECS Cluster"

# ALB
ALB=$(aws elbv2 describe-load-balancers \
  --names day11-alb \
  --region $REGION \
  --query "LoadBalancers[].LoadBalancerName" \
  --output text 2>/dev/null)

check "$ALB" "Application Load Balancer"

# Target Group
TG=$(aws elbv2 describe-target-groups \
  --names day11-tg \
  --region $REGION \
  --query "TargetGroups[].TargetGroupName" \
  --output text 2>/dev/null)

check "$TG" "Target Group"

# DynamoDB
DDB=$(aws dynamodb describe-table \
  --table-name day11-notes \
  --region $REGION \
  --query "Table.TableName" \
  --output text 2>/dev/null)

check "$DDB" "DynamoDB Table"

# ECR
ECR=$(aws ecr describe-repositories \
  --repository-names day11-notes-app \
  --region $REGION \
  --query "repositories[].repositoryName" \
  --output text 2>/dev/null)

check "$ECR" "ECR Repository"

# VPC
VPC=$(aws ec2 describe-vpcs \
  --filters Name=cidr,Values=10.11.0.0/16 \
  --region $REGION \
  --query "Vpcs[].VpcId" \
  --output text 2>/dev/null)

check "$VPC" "VPC"

echo "----------------------------------"

# Optional: S3 backend bucket check
BUCKET_EXISTS=$(aws s3api head-bucket --bucket $S3_BUCKET 2>/dev/null && echo "yes")

if [ "$BUCKET_EXISTS" == "yes" ]; then
  echo "ℹ S3 backend bucket still exists (expected): $S3_BUCKET"
else
  echo "✓ S3 backend bucket not found"
fi

echo "Verification complete."