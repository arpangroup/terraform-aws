
# Add an Alarm
resource "aws_cloudwatch_metric_alarm" "TF_ALARM_cpu_utilization" {
  alarm_name          = "tf-high_cpu_utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2 # the metric must meet the condition for 2 consecutive periods before the alarm state changes.
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2" # A container for CloudWatch metrics that groups related metrics. other namespaces are ["AWS/S3", "AWS/ELB", "AWS/RDS"]
  period              = 120 # The time interval (in seconds) over which the metric is aggregated for evaluation; period = 120 means metrics are collected and averaged over a 2-minute period.
  statistic           = "Average"
  threshold           = 80  # new instance will be created once CPU utilization is higher than 80%
  actions_enabled     = false
  alarm_description   = "This alarm triggers when CPU utilization exceeds 80%"

  #   dimensions          = { # Key-value pairs that refine the metric to specific instances, resources, or groups.
  #     "AutoScalingGroupName" = aws_autoscaling_group.TF_ASG.name # Filters the metric to the specified Auto Scaling Group.
  #   }
}


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
