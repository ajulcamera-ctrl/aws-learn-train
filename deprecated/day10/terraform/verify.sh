#!/bin/bash
set -e

REGION="eu-north-1"

echo "Verifying Day10 resources in $REGION..."
echo "-----------------------------------------"

echo ""
echo "ECS Clusters:"
aws ecs list-clusters --region $REGION \
  --query "clusterArns[?contains(@, 'day10')]" \
  --output text

echo ""
echo "ECS Services:"
aws ecs list-services --cluster day10-cluster --region $REGION 2>/dev/null || echo "None"

echo ""
echo "Task Definitions:"
aws ecs list-task-definitions --region $REGION \
  --query "taskDefinitionArns[?contains(@, 'day10')]" \
  --output text

echo ""
echo "Load Balancers:"
aws elbv2 describe-load-balancers --region $REGION \
  --query "LoadBalancers[?contains(LoadBalancerName, 'day10')].LoadBalancerName" \
  --output text

echo ""
echo "Target Groups:"
aws elbv2 describe-target-groups --region $REGION \
  --query "TargetGroups[?contains(TargetGroupName, 'day10')].TargetGroupName" \
  --output text

echo ""
echo "Security Groups:"
aws ec2 describe-security-groups --region $REGION \
  --query "SecurityGroups[?contains(GroupName, 'day10')].GroupName" \
  --output text

echo ""
echo "DynamoDB Tables:"
aws dynamodb list-tables --region $REGION \
  --query "TableNames[?contains(@, 'day10')]" \
  --output text

echo ""
echo "ECR Repositories:"
aws ecr describe-repositories --region $REGION \
  --query "repositories[?contains(repositoryName, 'day10')].repositoryName" \
  --output text 2>/dev/null || echo "None"

echo ""
echo "S3 Buckets:"
aws s3api list-buckets \
  --query "Buckets[?contains(Name, 'day10')].Name" \
  --output text

echo ""
echo "CloudWatch Log Groups:"
aws logs describe-log-groups --region $REGION \
  --query "logGroups[?contains(logGroupName, 'day10')].logGroupName" \
  --output text

echo ""
echo "-----------------------------------------"
echo "If all sections are empty → Day10 is fully destroyed."