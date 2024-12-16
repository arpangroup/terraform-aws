# Create Load Balancer
resource "aws_lb" "TF_ALB" {
  name               = "example-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.TF_ALB_SG.id]
  subnets            = var.subnets

  enable_deletion_protection = false
}

# Create Listener
resource "aws_lb_listener" "TF_ALB_LISTENER" {
  load_balancer_arn = aws_lb.TF_ALB.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_TG.arn
  }
}