output "lb_dns" {
  value = aws_lb.this.dns_name
}

output "lb_arn" {
  value = aws_lb.this.arn
}