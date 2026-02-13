#!/bin/bash
set -e

REGION="eu-north-1"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
S3_BUCKET="tfstate-$ACCOUNT_ID-$REGION"

read -p "Enter your domain (example.com): " DOMAIN_NAME

echo "Ensuring S3 backend bucket exists..."
aws s3api head-bucket --bucket $S3_BUCKET 2>/dev/null || \
aws s3api create-bucket \
  --bucket $S3_BUCKET \
  --region $REGION \
  --create-bucket-configuration LocationConstraint=$REGION

cat > backend.tf <<EOF
terraform {
  backend "s3" {
    bucket = "$S3_BUCKET"
    key    = "day11/terraform.tfstate"
    region = "$REGION"
  }
}
EOF

echo "Building Docker..."
cd ../app
bash build.sh
IMAGE_URL=$(bash push.sh)
cd ../terraform

terraform init
terraform apply \
  -var="domain_name=$DOMAIN_NAME" \
  -var="image_url=$IMAGE_URL" \
  -auto-approve

echo "Deployment complete."
terraform output alb_dns