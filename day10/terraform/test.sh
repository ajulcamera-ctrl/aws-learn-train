#!/bin/bash
set -e

ALB=$(terraform output -raw alb_dns)

echo "ALB DNS: $ALB"
echo ""

echo "Testing /health..."
curl http://$ALB/health
echo ""
echo ""

echo "Posting test note..."
curl -X POST http://$ALB/notes \
  -H "Content-Type: application/json" \
  -d '{"note":"test note from day10"}'
echo ""
echo ""

echo "Fetching all notes..."
curl http://$ALB/notes
echo ""