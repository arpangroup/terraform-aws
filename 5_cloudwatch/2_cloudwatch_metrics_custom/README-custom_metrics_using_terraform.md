# Create and manage CloudWatch Custom metrics

## Step1: Define CloudWatch Custom Metric:
````hcl
resource "aws_cloudwatch_metric_alarm" "example_metric" {
  alarm_name          = "ExampleAlarm"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "ExampleMetric"
  namespace           = "CustomNamespace"
  period              = 60
  statistic           = "Average"
  threshold           = 100
  actions_enabled     = false

  dimensions = {
    InstanceId = "i-1234567890abcdef0"
  }
}
````
- metric_name: Name of your custom metric.
- namespace: Logical grouping (e.g., CustomNamespace).
- dimensions: Key-value pairs to filter the metric data.


## Step2: Push Custom Metrics Using AWS CLI or SDK
````bash
aws cloudwatch put-metric-data \
  --metric-name ExampleMetric \
  --namespace CustomNamespace \
  --value 123 \
  --dimensions InstanceId=i-1234567890abcdef0
````

## Step3: Verify in AWS Console:
- Navigate to **CloudWatch > Alarms or CloudWatch > Metrics**.
- Confirm the metric and alarm are active.