#!/bin/bash
set -e

# Get the latest running task in day6-cluster
TASK_ID=$(aws ecs list-tasks --cluster day6-cluster --desired-status RUNNING --query 'taskArns[0]' --output text)

if [ "$TASK_ID" = "None" ]; then
  echo "No running task found. Run run-task.sh first."
  exit 1
fi

echo "Found task: $TASK_ID"
echo "Opening shell into container..."

aws ecs execute-command \
  --cluster day6-cluster \
  --task "$TASK_ID" \
  --container awscli \
  --interactive \
  --command "/bin/sh"