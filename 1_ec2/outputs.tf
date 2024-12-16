output "web_apps" {
  value = aws_instance.web_app[*].public_ip
}