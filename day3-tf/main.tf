provider "aws" {
  region = "us-east-1"
}

# We'll create an S3 bucket for testing
resource "aws_s3_bucket" "day3_bucket" {
  bucket = "aws-day3-terraform-${random_id.bucket_id.hex}"
}

resource "random_id" "bucket_id" {
  byte_length = 4
}