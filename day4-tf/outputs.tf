output "bucket_name" {
  value = aws_s3_bucket.demo_bucket.bucket
}

output "role_name" {
  value = aws_iam_role.demo_role.name
}
