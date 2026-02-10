#!/bin/bash
set -e

echo "==== VERIFYING ECS CLUSTERS ===="
CLUSTERS=$(aws ecs list-clusters --query "clusterArns" --output text)
if [ -z "$CLUSTERS" ]; then
    echo "✅ No ECS clusters found"
else
    echo "⚠ ECS clusters still exist:"
    echo "$CLUSTERS"
fi

echo ""
echo "==== VERIFYING ECS SERVICES ===="
for CLUSTER in $CLUSTERS; do
    SERVICES=$(aws ecs list-services --cluster $CLUSTER --query "serviceArns" --output text)
    if [ -z "$SERVICES" ]; then
        echo "✅ No services in $CLUSTER"
    else
        echo "⚠ Services still exist in $CLUSTER:"
        echo "$SERVICES"
    fi
done

echo ""
echo "==== VERIFYING ECS TASKS ===="
for CLUSTER in $CLUSTERS; do
    TASKS=$(aws ecs list-tasks --cluster $CLUSTER --query "taskArns" --output text)
    if [ -z "$TASKS" ]; then
        echo "✅ No tasks in $CLUSTER"
    else
        echo "⚠ Tasks still exist in $CLUSTER:"
        echo "$TASKS"
    fi
done

echo ""
echo "==== VERIFYING ECR REPOSITORIES ===="
REPOS=$(aws ecr describe-repositories --query "repositories[*].repositoryName" --output text | grep -E 'day[5-8]')
if [ -z "$REPOS" ]; then
    echo "✅ No Day5–Day8 ECR repos found"
else
    echo "⚠ ECR repos still exist:"
    echo "$REPOS"
fi

echo ""
echo "==== VERIFYING LOAD BALANCERS (ALB) ===="
LBS=$(aws elbv2 describe-load-balancers --query "LoadBalancers[*].LoadBalancerName" --output text | grep -E 'day[5-8]')
if [ -z "$LBS" ]; then
    echo "✅ No Day5–Day8 ALBs found"
else
    echo "⚠ ALBs still exist:"
    echo "$LBS"
fi

echo ""
echo "==== VERIFYING TARGET GROUPS ===="
TGS=$(aws elbv2 describe-target-groups --query "TargetGroups[*].TargetGroupName" --output text | grep -E 'day[5-8]')
if [ -z "$TGS" ]; then
    echo "✅ No Day5–Day8 target groups found"
else
    echo "⚠ Target groups still exist:"
    echo "$TGS"
fi

echo ""
echo "==== VERIFYING IAM ROLES ===="
ROLES=$(aws iam list-roles --query "Roles[*].RoleName" --output text | grep -E 'day[5-8]')
if [ -z "$ROLES" ]; then
    echo "✅ No Day5–Day8 IAM roles found"
else
    echo "⚠ IAM roles still exist:"
    echo "$ROLES"
fi

echo ""
echo "==== VERIFYING CLOUDWATCH LOG GROUPS ===="
LOGS=$(aws logs describe-log-groups --query "logGroups[*].logGroupName" --output text | grep -E 'day[5-8]')
if [ -z "$LOGS" ]; then
    echo "✅ No Day5–Day8 CloudWatch log groups found"
else
    echo "⚠ CloudWatch log groups still exist:"
    echo "$LOGS"
fi

echo ""
echo "==== VERIFICATION COMPLETE ===="