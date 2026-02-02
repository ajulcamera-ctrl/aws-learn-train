#!/bin/bash
set -e

REGION=$(aws configure get region)
BUCKET_NAME="aws-day2-s3-$RANDOM-$RANDOM"

echo "Region: $REGION"
echo "Bucket name: $BUCKET_NAME"

echo "Creating S3 bucket..."
aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

echo "Creating test file..."
echo "hello from day 2" > test.txt

echo "Uploading file to S3..."
aws s3 cp test.txt s3://$BUCKET_NAME/test.txt

echo "Listing bucket contents..."
aws s3 ls s3://$BUCKET_NAME/

echo "Downloading file..."
aws s3 cp s3://$BUCKET_NAME/test.txt downloaded.txt

echo "Downloaded file contents:"
cat downloaded.txt

echo "DAY 2 COMPLETE"
echo "BUCKET_NAME=$BUCKET_NAME"