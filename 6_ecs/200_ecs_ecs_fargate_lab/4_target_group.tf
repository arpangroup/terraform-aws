resource "aws_lb_target_group" "TF_ECS_TG" {
  name     = "TG"
  port     = 8080      # Port Specifies Where to Send Traffic on the Target
  protocol = "HTTP"
  target_type = "ip" # [instance, ip, alb]
  vpc_id   = aws_vpc.TF_VPC

  tags = {
    Name = "TF_TG"
  }
}

/*resource "aws_lb_target_group" "TF_DB_TG" {
  name        = "db-tg"
  port        = 1521
  protocol    = "TCP"
  vpc_id      = "vpc-12345678"
  target_type = "instance"
}*/