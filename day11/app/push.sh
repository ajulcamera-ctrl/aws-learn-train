#!/bin/bash
set -e

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REPO="day11-notes-app"

aws ecr describe-repositories --repository-names $REPO >/dev/null 2>&1 || \
aws ecr create-repository --repository-name $REPO

aws ecr get-login-password --region $REGION | \
docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker tag $REPO:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest

echo "$ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/$REPO:latest"