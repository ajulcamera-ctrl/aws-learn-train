#!/bin/bash
set -e

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO="day11-notes-app"

echo "Running terraform destroy..."
terraform destroy -auto-approve

echo "Checking for ECR repository..."

if aws ecr describe-repositories \
    --repository-names $REPO \
    --region $REGION >/dev/null 2>&1; then

  echo "Deleting ECR images..."
  IMAGE_IDS=$(aws ecr list-images \
      --repository-name $REPO \
      --region $REGION \
      --query 'imageIds[*]' \
      --output json)

  if [ "$IMAGE_IDS" != "[]" ]; then
    aws ecr batch-delete-image \
      --repository-name $REPO \
      --region $REGION \
      --image-ids "$IMAGE_IDS"
  fi

  echo "Deleting ECR repository..."
  aws ecr delete-repository \
      --repository-name $REPO \
      --region $REGION \
      --force

  echo "✓ ECR repository deleted"

else
  echo "✓ ECR repository does not exist"
fi

echo "Destroy complete."