#!/bin/bash
set -e

cd terraform
terraform output

echo "Checking CloudWatch logs..."
aws logs describe-log-groups --log-group-name-prefix /ecs

echo "Checking DynamoDB tables..."
aws dynamodb list-tables

echo "Verification complete!"