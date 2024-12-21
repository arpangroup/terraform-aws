# ALB
resource "aws_lb" "TF_ALB" {
  name                       = "tf-${var.project}-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.vpc.security_group.id]
  subnets                    = var.vpc.public_subnets[*].id
  enable_deletion_protection = false

  /*access_logs {
    bucket = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = false
  }*/

  tags = {
    Name = "tf-${var.project}-alb"
  }
}

# ALB Target Group
resource "aws_lb_target_group" "TF_TG" {
  name        = "tf-target-group"
  port        = 8080        # Forward traffic to port 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc.id
  target_type = "instance"


  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol = "HTTP"
    #matcher            = "200-399"
    matcher             = "200"
  }

  tags = {
    Name = "tf-ec2-tg"
  }
}

# ALB Listener
resource "aws_lb_listener" "TF_ALB_HTTP_TCP_LISTENER" {
  load_balancer_arn = aws_lb.TF_ALB.arn
  port              = 80          # ALB listens on port 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.TF_TG.arn
  }
}