#!/bin/bash
set -e

# -----------------------------
# Day 8 ECS + ALB Curl Test
# -----------------------------

# Get ALB DNS from Terraform
ALB_DNS=$(terraform output -raw alb_dns)
echo "ALB DNS: $ALB_DNS"

# Test /health endpoint
echo "Testing /health endpoint..."
curl -s http://$ALB_DNS/health
echo ""

# Post a test note
echo "Posting a test note..."
curl -s -X POST http://$ALB_DNS/notes \
  -H "Content-Type: application/json" \
  -d '{"note":"test note from CloudShell"}'
echo ""

# Fetch all notes
echo "Fetching all notes..."
curl -s http://$ALB_DNS/notes
echo ""