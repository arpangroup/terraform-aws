resource "aws_lb_target_group" "TF_TG" {
  name     = "TG"
  port     = 80
  protocol = "HTTP"
  target_type = "ip" # [instance, ip, ...]
  vpc_id   = aws_vpc.TF_VPC

  tags = {
    Name = "TF_TG"
  }
}