#!/bin/bash
set -e

BASE_DIR=~/aws-learn-train

echo "Cleaning Terraform caches under $BASE_DIR"
echo ""

# Remove .terraform directories
find "$BASE_DIR" -type d -name ".terraform" -prune -exec rm -rf {} +

# Remove lock files
find "$BASE_DIR" -type f -name ".terraform.lock.hcl" -delete

echo ""
echo "Terraform cleanup complete."
echo ""

df -kh ~