output "alb_dns_name" {
  value = aws_lb.TF_ALB.dns_name
}

output "instances" {
  value = aws_instance.webapp[*].public_ip
}