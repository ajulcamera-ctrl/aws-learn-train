output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "ecr_repo" {
  value = aws_ecr_repository.app.repository_url
}

output "dynamodb_workouts_table" {
  value = aws_dynamodb_table.workouts.name
}

output "dynamodb_hikes_table" {
  value = aws_dynamodb_table.hikes.name
}