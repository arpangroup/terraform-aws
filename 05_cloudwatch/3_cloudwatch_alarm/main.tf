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
