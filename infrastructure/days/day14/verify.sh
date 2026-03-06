#!/bin/bash
set -e

echo "Verifying Terraform outputs..."
terraform output

echo "Checking CloudWatch logs..."
aws logs describe-log-groups --log-group-name-prefix /ecs/day14

echo "Verification complete!"
