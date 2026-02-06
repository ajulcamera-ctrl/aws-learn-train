#!/bin/bash
set -e

echo "Checking ECS cluster..."
CLUSTER=$(aws ecs describe-clusters --clusters day6-cluster --query 'clusters[0].status' --output text 2>/dev/null)
[ "$CLUSTER" = "None" ] && echo "✅ Cluster gone" || echo "❌ Cluster still exists"

echo "Checking ECS task definitions..."
TASKDEF=$(aws ecs list-task-definitions --family-prefix day6-task --query 'taskDefinitionArns' --output text)
[ -z "$TASKDEF" ] && echo "✅ Task definition gone" || echo "❌ Task definition still exists"

echo "Checking ECS tasks..."
TASKS=$(aws ecs list-tasks --cluster day6-cluster --query 'taskArns' --output text)
[ -z "$TASKS" ] && echo "✅ No running tasks" || echo "❌ Tasks still running: $TASKS"

echo "Checking IAM role..."
ROLE=$(aws iam list-roles --query 'Roles[?contains(RoleName, `ecs-task-role`)].RoleName' --output text)
[ -z "$ROLE" ] && echo "✅ IAM role gone" || echo "❌ IAM role still exists: $ROLE"

echo "All checks complete."