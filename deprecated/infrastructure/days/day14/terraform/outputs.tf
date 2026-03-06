output "alb_dns" {
  value = aws_lb.main.dns_name
}

output "ecr_repo" {
  value = aws_ecr_repository.app.repository_url
}
