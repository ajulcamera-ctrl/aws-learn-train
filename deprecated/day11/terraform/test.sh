#!/bin/bash
ALB=$(terraform output -raw alb_dns)

echo "Testing health..."
curl http://$ALB/health

echo "Posting note..."
curl -X POST http://$ALB/notes \
  -H "Content-Type: application/json" \
  -d '{"note":"hello from day11"}'

echo "Fetching notes..."
curl http://$ALB/notes