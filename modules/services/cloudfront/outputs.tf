output "id" {
  value = aws_cloudfront_distribution.main.id
  sensitive = true
}

output "domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
  sensitive = true
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.main.domain_name}"
}