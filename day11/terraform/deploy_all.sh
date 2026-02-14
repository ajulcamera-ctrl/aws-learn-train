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
    key    = "terraform.tfstate"
    region = "$REGION"
  }
}
EOF

echo "Initializing Terraform..."
terraform init

echo "Running first apply (will output ACM DNS validation)..."
terraform apply -var "domain_name=$DOMAIN_NAME" -auto-approve

echo
echo "!!! Copy the certificate validation CNAME record below into Namecheap DNS !!!"
terraform output certificate_dns_validation_record
echo
read -p "Press ENTER after adding CNAME in Namecheap and it has propagated..."

echo "Running second apply to attach certificate and enable HTTPS..."
terraform apply -var "domain_name=$DOMAIN_NAME" -auto-approve

echo
echo "HTTPS should now be enabled at: https://notes.$DOMAIN_NAME"
