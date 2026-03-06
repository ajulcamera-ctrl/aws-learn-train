#!/bin/bash
set -e

terraform destroy -auto-approve

aws ecr delete-repository --repository-name day9-notes --force || true

aws logs delete-log-group --log-group-name /ecs/day9 || true