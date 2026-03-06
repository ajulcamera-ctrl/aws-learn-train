#!/bin/bash
echo "Checking if RDS and EC2 resources were destroyed..."

# Check RDS
RDS_COUNT=$(aws rds describe-db-instances --region eu-north-1 \
  --query "DBInstances[?DBInstanceIdentifier=='day12-postgres'] | length(@)")

# Check EC2
EC2_COUNT=$(aws ec2 describe-instances --region eu-north-1 \
  --filters "Name=tag:Name,Values=day12-ec2" \
  --query "Reservations | length(@)")

if [[ $RDS_COUNT -eq 0 && $EC2_COUNT -eq 0 ]]; then
  echo "✅ Destroy verified: No RDS or EC2 instances found."
else
  echo "⚠️ Destroy incomplete:"
  echo "RDS instances count: $RDS_COUNT"
  echo "EC2 instances count: $EC2_COUNT"
fi