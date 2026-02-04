#!/bin/bash
rm -rf ~/.terraform
rm -rf ~/aws-learn-train/**/.terraform
rm -f  ~/aws-learn-train/**/.terraform.lock.hcl
echo "Terraform cache cleaned"
df -kh ~