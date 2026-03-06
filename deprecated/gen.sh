#!/bin/bash
# gen.sh - Generate full SummitForge course scaffold (Day14→Day30)
set -e

echo "Generating SummitForge repo structure..."

# Base paths
APP_DIR="app"
BACKEND_DIR="$APP_DIR/backend"
FRONTEND_DIR="$APP_DIR/frontend"
INFRA_DIR="infrastructure"
MODULES_DIR="$INFRA_DIR/modules"
DAYS_DIR="$INFRA_DIR/days"

# Create app folders
mkdir -p "$BACKEND_DIR/api" "$BACKEND_DIR/services" "$BACKEND_DIR/storage"
mkdir -p "$FRONTEND_DIR/src" "$FRONTEND_DIR/public"

# Create modules folder
mkdir -p "$MODULES_DIR"

# Create day folders
for DAY in {14..30}; do
    mkdir -p "$DAYS_DIR/day$DAY/terraform"
    touch "$DAYS_DIR/day$DAY/deploy.sh" "$DAYS_DIR/day$DAY/destroy.sh" "$DAYS_DIR/day$DAY/test.sh" "$DAYS_DIR/day$DAY/verify.sh"
done

echo "Generating Terraform skeletons and scripts..."

for DAY in {14..30}; do
    TF_DIR="$DAYS_DIR/day$DAY/terraform"

    # main.tf
    cat > "$TF_DIR/main.tf" <<EOL
# day$DAY main.tf
terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.aws_region
}

# Modules placeholders
# Feature flags determine which modules are active
EOL

    # variables.tf
    cat > "$TF_DIR/variables.tf" <<EOL
variable "aws_region" {
  type    = string
  default = "eu-north-1"
}

variable "enable_dynamodb" {
  type    = bool
  default = $([ "$DAY" -ge 19 ] && echo "true" || echo "false")
}

variable "enable_rds" {
  type    = bool
  default = $([ "$DAY" -ge 22 ] && echo "true" || echo "false")
}

variable "enable_redis" {
  type    = bool
  default = $([ "$DAY" -ge 23 ] && echo "true" || echo "false")
}

variable "enable_s3" {
  type    = bool
  default = $([ "$DAY" -ge 24 ] && echo "true" || echo "false")
}

variable "enable_waf" {
  type    = bool
  default = $([ "$DAY" -ge 27 ] && echo "true" || echo "false")
}
EOL

    # outputs.tf
    cat > "$TF_DIR/outputs.tf" <<EOL
output "alb_dns" {
  value = "placeholder-alb-dns"
}

output "frontend_url" {
  value = "placeholder-frontend-url"
}
EOL

    # versions.tf
    cat > "$TF_DIR/versions.tf" <<EOL
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0"
    }
  }
  required_version = ">= 1.5"
}
EOL

    # deploy.sh
    cat > "$DAYS_DIR/day$DAY/deploy.sh" <<'EOL'
#!/bin/bash
cd terraform
terraform init
terraform apply -auto-approve
EOL

    # destroy.sh
    cat > "$DAYS_DIR/day$DAY/destroy.sh" <<'EOL'
#!/bin/bash
cd terraform
terraform destroy -auto-approve
# Clean ECR repos
aws ecr describe-repositories --query 'repositories[*].repositoryName' --output text | xargs -n1 -I {} aws ecr delete-repository --repository-name {} --force || true
EOL

    # test.sh
    cat > "$DAYS_DIR/day$DAY/test.sh" <<'EOL'
#!/bin/bash
echo "Testing deployed resources..."
echo "This script will later hit FastAPI endpoints and validate storage."
EOL

    # verify.sh
    cat > "$DAYS_DIR/day$DAY/verify.sh" <<'EOL'
#!/bin/bash
echo "Verifying infrastructure..."
echo "Checks that Terraform outputs exist and resources are as expected."
EOL
done

echo "Generating backend FastAPI scaffold..."

# main.py
cat > "$BACKEND_DIR/main.py" <<'EOL'
from fastapi import FastAPI
from api import workouts, hikes
from config import STORAGE_TYPE
from storage import memory, dynamodb, postgres, redis_cache

app = FastAPI()

# Storage selection
if STORAGE_TYPE == "memory":
    workout_store = memory.WorkoutMemoryStorage()
    hike_store = memory.HikeMemoryStorage()
elif STORAGE_TYPE == "dynamodb":
    workout_store = dynamodb.WorkoutDynamoStorage()
    hike_store = dynamodb.HikeDynamoStorage()
elif STORAGE_TYPE == "postgres":
    workout_store = postgres.WorkoutPostgresStorage()
    hike_store = postgres.HikePostgresStorage()
elif STORAGE_TYPE == "redis":
    workout_store = redis_cache.WorkoutRedisCache()
    hike_store = redis_cache.HikeRedisCache()
else:
    raise Exception("Unknown STORAGE_TYPE")

# Include routers
app.include_router(workouts.router, prefix="/workouts", tags=["workouts"])
app.include_router(hikes.router, prefix="/hikes", tags=["hikes"])

@app.get("/health")
def health():
    return {"status": "ok"}
EOL

# Placeholder backend files
for FILE in config.py models.py api/workouts.py api/hikes.py services/workout_service.py services/hike_service.py storage/base.py storage/memory.py storage/dynamodb.py storage/postgres.py storage/redis_cache.py requirements.txt Dockerfile; do
    mkdir -p "$(dirname "$BACKEND_DIR/$FILE")"
    touch "$BACKEND_DIR/$FILE"
done

echo "Generating frontend React scaffold..."
cat > "$FRONTEND_DIR/package.json" <<EOL
{
  "name": "summitforge-frontend",
  "version": "0.1.0",
  "private": true,
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-scripts": "5.0.1"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build"
  }
}
EOL

touch "$FRONTEND_DIR/public/index.html" "$FRONTEND_DIR/src/App.js"

echo "SummitForge full scaffold for all days generated successfully!"
