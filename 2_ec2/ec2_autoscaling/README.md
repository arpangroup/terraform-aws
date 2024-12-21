# Autoscaling Group

## Steps:
1. VPC + Multi AZ
2. Launch Template
3. ALB + TargetGroup
4. AutoScalingGroup (LaunchTemplate + Max/Min Size + TG)
   - Scale-up policy   (CPU Utilization > 30%)
   - Scale-down policy (CPU Utilization < 5%)
5. Cloudwatch Alarm & ELB HealthCheck
   - scale-up alarm (trigger above Scale-up policy when CPU Utilization > 30%)
   - scale-down alarm(trigger above Scale-down policy when CPU Utilization < 5%)



## EC2 Auto Scaling Group
````hcl
resource "aws_launch_template" "TF_LAUNCH_TEMPLATE" {
   name          = "tf-launch-template"
   image_id      = var.ami
   instance_type = "t2.micro"
   key_name      = var.key_name


   network_interfaces {
      security_groups             = [var.vpc.security_group.id]
      associate_public_ip_address = true
   }

   # user_data = filebase64("${path.module}/ec2-init.sh")
   user_data = base64encode(<<-EOF
    #!/bin/bash
    yum update -y
    yum install -y httpd

    instance_ip=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
    echo "Hello from instance IP: $instance_ip" > /var/www/html/index.html

    systemctl start httpd
    systemctl enable httpd
  EOF
   )
}

# Auto Scaling Group
resource "aws_autoscaling_group" "TF_ASG" {
   name                 = "tf-${var.project}-asg"
   desired_capacity     = 2 # all time UP or RUN
   max_size             = 3
   min_size             = 1
   #health_check_grace_period = 300
   #health_check_type    = "ELB" # ["EC2", "ELB"]
   #target_group_arns    = [aws_lb_target_group.TF_TG.arn]
   vpc_zone_identifier  = [var.vpc.public_subnets[0].id, var.vpc.public_subnets[1].id]


   launch_template {
      id      = aws_launch_template.TF_LAUNCH_TEMPLATE.id
      version = "$Latest"
   }

   /*enabled_metrics = [
     "GroupMinSize",
     "GroupMaxSize",
     "GroupDesiredCapacity",
     "GroupInServiceInstances",
     "GroupTotalInstances"
   ]*/

   metrics_granularity = "1Minute"

   tags = [
      {
         key                 = "Name"
         value               = "TF-ASG-Instance"
         propagate_at_launch = true
      }
   ]
}

# Scaling Policies
resource "aws_autoscaling_policy" "TF_scale_up" {
   name                   = "tf-${var.project}-asg-scale-up"
   autoscaling_group_name = aws_autoscaling_group.TF_ASG.name
   adjustment_type        = "ChangeInCapacity"
   scaling_adjustment     = 1 # increasing instance by 1
   cooldown               = 300
   policy_type            = "SimpleScaling"
}


resource "aws_autoscaling_policy" "TF_scale_down" {
   name                   = "tf-${var.project}-asg-scale-down"
   autoscaling_group_name = aws_autoscaling_group.TF_ASG.name
   adjustment_type        = "ChangeInCapacity"
   scaling_adjustment     = -1 # decreasing instance by 1
   cooldown               = 300
   policy_type            = "SimpleScaling"
}
````
**Scaling Policies:** The `scale_up` and `scale_down` policies adjust the ASG capacity. You can customize scaling triggers by adding AWS CloudWatch alarms.


## Optional: Attach a Load Balancer
````hcl
resource "aws_autoscaling_group" "TF_ASG" {
  ....
  target_group_arns    = [aws_lb_target_group.TF_TG.arn]
  ....
}

# Application Load Balancer
resource "aws_lb" "alb" {
  name               = "my-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = ["subnet-12345678", "subnet-23456789"] # Replace with your subnet IDs
}

# ALB Target Group
resource "aws_lb_target_group" "TF_TG" {
   name        = "my-target-group"
   port        = 80
   protocol    = "HTTP"
   vpc_id      = "vpc-12345678" # Replace with your VPC ID
   target_type = "instance"
}

# ALB Listener
resource "aws_lb_listener" "listener" {
   load_balancer_arn = aws_lb.alb.arn
   port              = 80
   protocol          = "HTTP"

   default_action {
      type             = "forward"
      target_group_arn = aws_lb_target_group.tg.arn
   }
}
````
The `target_group_arns` property in the `aws_autoscaling_group` resource connects the ASG instances to the ALB.