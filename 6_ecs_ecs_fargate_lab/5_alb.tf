resource "aws_lb" "TF_ALB" {
  name               = ""
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TF_SG.id]
  subnets            = [aws_subnet.TF_PUBLIC_SUBNET.id]

  tags = {
    Name = "TF_ALB"
  }
}

resource "aws_lb_listener" "TF_ALB_LISTENER" {
  load_balancer_arn = aws_lb.TF_ALB.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_TG.id
  }
}