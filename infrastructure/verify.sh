#!/bin/bash
set -e

cd terraform
terraform output

echo "Checking CloudWatch logs..."
aws logs describe-log-groups --log-group-name-prefix /ecs

echo "Checking DynamoDB tables..."
aws dynamodb list-tables

echo "Checking WAF..."
aws wafv2 list-web-acls --scope REGIONAL

echo "Checking Route53..."
aws route53 list-hosted-zones

echo "Verification complete!"