#!/bin/bash
set -e

cd ~/aws-learn-train/day7/app

echo "Creating ECR repo (if not exists)..."
aws ecr create-repository --repository-name day8-notes || true

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Building image..."
docker build -t day8-notes .

echo "Tagging image..."
docker tag day8-notes:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/day8-notes:latest

echo "Pushing image..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/day8-notes:latest

echo ""
echo "DONE."
echo "Image URI:"
echo "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/day8-notes:latest"