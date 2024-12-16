# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group
resource "aws_lb_target_group" "TF_TG" {
  name        = "example-tg"
  port        = 80 # Port Specifies Where to Send Traffic on the Target
  protocol    = "HTTP"
  target_type = "instance" # [instance, ip, alb]
  vpc_id      = aws_vpc.TF_VPC.id

  health_check {
    enabled             = true
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    #matcher            = "200-399"
    matcher = "200"

  }
}

# Register EC2 Instances with Target Group
resource "aws_lb_target_group_attachment" "example_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.TF_TG.arn
  target_id        = aws_instance.webapp[count.index].id
  port             = 80
}