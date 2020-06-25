output "url" {
  value = "http://${aws_lb.main.dns_name}"
}

output "lb_dns_name" {
  value = aws_lb.main.dns_name
  sensitive = true
}

output "lb_id" {
  value = aws_lb.main.id
  sensitive = true
}