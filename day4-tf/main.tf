provider "aws" {
  region = "us-east-1"
}

resource "random_id" "suffix" {
  byte_length = 4
}

resource "aws_s3_bucket" "demo_bucket" {
  bucket = "day4-iam-demo-${random_id.suffix.hex}"
}

resource "aws_iam_role" "demo_role" {
  name = "day4-iam-role-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "s3_read_policy" {
  name = "day4-s3-read-${random_id.suffix.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:ListBucket",
        "s3:GetObject"
      ]
      Resource = [
        aws_s3_bucket.demo_bucket.arn,
        "${aws_s3_bucket.demo_bucket.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_policy" {
  role       = aws_iam_role.demo_role.name
  policy_arn = aws_iam_policy.s3_read_policy.arn
}
