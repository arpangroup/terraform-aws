# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_listener

# Create Load Balancer
resource "aws_lb" "TF_ALB" {
  name                       = "tf-alb"
  internal                   = false
  load_balancer_type         = "application"                     # [application, gateway, network]
  security_groups            = [aws_security_group.TF_ALB_SG.id] # Load Balancer's security group
  subnets                    = aws_subnet.TF_PUBLIC_SUBNET[*].id # public subnets,
  enable_deletion_protection = false

  /*access_logs {
    bucket = aws_s3_bucket.lb_logs.id
    prefix  = "test-lb"
    enabled = false
  }*/
}


# Create Listener
resource "aws_lb_listener" "TF_ALB_HTTP_TCP_LISTENER" {
  load_balancer_arn = aws_lb.TF_ALB.arn
  port              = 80
  protocol          = "HTTP"
  #ssl_policy       = "ELBSecurityPolicy-2016-08"
  #certificate_arn  = "arn:aws:iam::187416307283:server-certificate/test_cert_rab3wuqwgja25ct3n4jdj2tzu4"


  default_action {
    type             = "forward" # [forward, redirect, Return Fixed Response:]
    target_group_arn = aws_lb_target_group.TF_TG.arn
  }
}

