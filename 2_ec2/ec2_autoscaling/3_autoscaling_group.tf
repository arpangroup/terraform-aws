# Auto Scaling Group
resource "aws_autoscaling_group" "TF_ASG" {
  name                 = "tf-${var.project}-asg"
  desired_capacity     = 2 # all time UP or RUN
  max_size             = 3
  min_size             = 1
  #health_check_grace_period = 300
  #health_check_type    = "ELB" # ["EC2", "ELB"]
  target_group_arns    = [aws_lb_target_group.TF_TG.arn]
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