#!/bin/bash
set -e

echo "Initializing Terraform..."
terraform init

echo "Applying Terraform..."
terraform apply -auto-approve

echo ""
echo "Deployment complete."
echo ""

echo "Frontend URL:"
terraform output frontend_url

echo ""
echo "ALB DNS:"
terraform output alb_dns