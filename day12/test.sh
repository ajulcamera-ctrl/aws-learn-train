#!/bin/bash
cd terraform

# Get EC2 public IP
EC2_IP=$(terraform output -raw ec2_public_ip)

echo "EC2 public IP: $EC2_IP"
echo "You can run the following command to see if the DB connection worked:"

echo "ssh ec2-user@$EC2_IP 'cat /home/ec2-user/db_test.txt'"

# Optional: direct run if SSH key is already set up
# ssh -o StrictHostKeyChecking=no ec2-user@$EC2_IP 'cat /home/ec2-user/db_test.txt'