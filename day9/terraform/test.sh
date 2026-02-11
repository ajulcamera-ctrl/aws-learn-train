#!/bin/bash
set -e

# Replace this with your actual ALB DNS
ALB_DNS=$(terraform output -raw alb_dns)
BASE_URL="http://$ALB_DNS"

echo "ALB DNS: $ALB_DNS"

echo "Testing /health endpoint..."
curl -s "$BASE_URL/health" | grep -q "ok" && echo "Health OK" || echo "Health FAILED"

echo "Posting a test note..."
curl -s -X POST "$BASE_URL/notes" -H "Content-Type: application/json" -d '{"note":"test note from shell"}' | jq

echo "Fetching all notes..."
curl -s "$BASE_URL/notes" | jq