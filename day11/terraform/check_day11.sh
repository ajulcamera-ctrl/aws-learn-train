#!/bin/bash
set -e

# Get ALB DNS from Terraform
ALB=$(terraform output -raw alb_dns_name)
echo "ALB DNS: $ALB"

# 1️⃣ DNS check
echo "Checking DNS..."
nslookup notes.1joule.com

# 2️⃣ Check ALB listeners
echo
echo "ALB listeners:"
aws elbv2 describe-listeners --load-balancer-arn $(terraform output -raw alb_arn) --region eu-north-1

# 3️⃣ Check target group health
TG_ARN=$(terraform output -raw target_group_arn)
echo
echo "Target group health:"
aws elbv2 describe-target-health --target-group-arn $TG_ARN --region eu-north-1

# 4️⃣ ECS tasks
CLUSTER=$(terraform output -raw ecs_cluster_name)
echo
echo "ECS tasks in cluster $CLUSTER:"
TASKS=$(aws ecs list-tasks --cluster $CLUSTER --region eu-north-1 --query 'taskArns' --output text)
if [ -z "$TASKS" ]; then
  echo "No ECS tasks running."
else
  aws ecs describe-tasks --cluster $CLUSTER --tasks $TASKS --region eu-north-1 --query 'tasks[*].[taskArn,lastStatus,containers[*].name,containers[*].lastStatus]' --output table
fi
