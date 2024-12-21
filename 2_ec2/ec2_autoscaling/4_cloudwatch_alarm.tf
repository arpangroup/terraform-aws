# scale up alarm
# alarm will trigger the ASG policy (scale/down) based on the metric (CPUUtilization), comparison
resource "aws_cloudwatch_metric_alarm" "TF_SCALE_UP_ALARM" {
  alarm_name          = "tf-${var.project}-asg-scale-up-alarm"
  alarm_description   = "asg-scale-up-cpu-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 30 # new instance will be created once CPU utilization is higher than 30
  dimensions          = {
    "AutoScalingGroupName" = aws_autoscaling_group.TF_ASG.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.TF_scale_up.arn]
}

# scale down alarm
resource "aws_cloudwatch_metric_alarm" "TF_SCALE_DOWN_ALARM" {
  alarm_name          = "tf-${var.project}-asg-scale-down-alarm"
  alarm_description   = "asg-scale-down-cpu-alarm"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 120
  statistic           = "Average"
  threshold           = 5 # No instance will be scale down when CPU utilization is lowe than 5%
  dimensions          = {
    "AutoScalingGroupName" = aws_autoscaling_group.TF_ASG.name
  }
  actions_enabled     = true
  alarm_actions       = [aws_autoscaling_policy.TF_scale_down.arn]
}
