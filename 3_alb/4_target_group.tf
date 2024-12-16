# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lb_target_group

# Create Target Group for EC2 Instances on Port 8080
resource "aws_lb_target_group" "TF_TG" {
  name        = "tf-tg"
  port        = 80 # Port Specifies Where to Send Traffic on the Target(eg: 8080)
  protocol    = "HTTP"
  target_type = "instance" # [instance, ip, alb]
  vpc_id      = aws_vpc.TF_VPC.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
    protocol            = "HTTP"
    #matcher            = "200-399"
    matcher = "200"
  }

  tags = {
    Name = "tf-ec2-tg"
  }
}

# Register EC2 Instances with Target Group
resource "aws_lb_target_group_attachment" "example_attachment" {
  count            = 2
  target_group_arn = aws_lb_target_group.TF_TG.arn
  target_id        = aws_instance.webapp[count.index].id
  port             = 80
}