#!/bin/bash
set -e

cd ../app

aws ecr create-repository --repository-name day9-notes || true

ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGION=$(aws configure get region)

aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com

docker build -t day9-notes .
docker tag day9-notes:latest $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/day9-notes:latest
docker push $ACCOUNT_ID.dkr.ecr.$REGION.amazonaws.com/day9-notes:latest