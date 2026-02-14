output "alb_dns_name" {
  value = aws_lb.app.dns_name
}

output "notes_https_url" {
  value = "https://notes.${var.domain_name}"
}

output "certificate_dns_validation_record" {
  value = aws_acm_certificate.notes_cert.domain_validation_options
}
