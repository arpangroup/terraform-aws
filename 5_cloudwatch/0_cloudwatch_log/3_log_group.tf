# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "TF_LOG_GROUP" {
  name              = "spring-app-logs"
  retention_in_days = 7 # how long log data is retained in the group before being automatically deleted.

  tags = {
    Environment = "Dev"
  }
}

# CloudWatch Log Stream: Sequential sets of log events from a single resource.
# EX: Logs from an EC2 instance or a Lambda function.
resource "aws_cloudwatch_log_stream" "TF_CLOUDWATCH_LOG_STREAM" {
  name           = "${aws_instance.TF_WEB_APP.id}-api-log"  # Dynamically set based on instance ID
  log_group_name = aws_cloudwatch_log_group.TF_LOG_GROUP.name
}