#!/bin/bash
set -e

ALB_DNS=$(cd terraform && terraform output -raw alb_dns)

echo "Testing health..."
curl -f http://$ALB_DNS/health

echo "Testing workouts API..."
curl -f http://$ALB_DNS/workouts/

echo "Testing hikes API..."
curl -f http://$ALB_DNS/hikes/

echo "All tests passed!"