# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "TF_TG" {
  name     = "example-tg"
  port     = 80        # Port Specifies Where to Send Traffic on the Target
  protocol = "HTTP"
  target_type = "ins" # [instance, ip, alb]
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
    protocol            = "HTTP"
    #matcher            = "200-399"
    matcher             = "200"

  }
}