#!/bin/bash
set -e

REGION="eu-north-1"
REPO="day10-notes"

echo "Destroying Terraform resources..."
terraform destroy -auto-approve

echo "Deleting ECR images..."
aws ecr batch-delete-image \
  --repository-name $REPO \
  --image-ids imageTag=latest \
  --region $REGION 2>/dev/null || true

echo "Deleting ECR repository..."
aws ecr delete-repository \
  --repository-name $REPO \
  --force \
  --region $REGION 2>/dev/null || true

echo "Cleanup complete."