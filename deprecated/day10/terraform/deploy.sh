#!/bin/bash
set -e

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO="day10-notes"

echo "Creating ECR repo if it doesn't exist..."
aws ecr describe-repositories --repository-names $REPO --region $REGION >/dev/null 2>&1 || \
aws ecr create-repository --repository-name $REPO --region $REGION

echo "Logging into ECR..."
aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

echo "Building Docker image..."
cd ../app
docker build -t $REPO .

echo "Tagging image..."
docker tag $REPO:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest

echo "Pushing image..."
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest

cd ../terraform
echo "Docker push complete."