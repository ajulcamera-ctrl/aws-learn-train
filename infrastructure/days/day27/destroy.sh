#!/bin/bash
cd terraform
terraform destroy -auto-approve
# Clean ECR repos
aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text | xargs -n1 -I {} aws ecr delete-repository --repository-name {} --force || true
