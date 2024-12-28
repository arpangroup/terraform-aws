# Create an AWS EventBridge rule that triggers a Lambda function
# Create an EventBridge rule
resource "aws_cloudwatch_event_rule" "my_event_rule" {
  name        = "my_event_rule"
  description = "Trigger Lambda based on specific event pattern"
  event_pattern = jsonencode({
    source = ["aws.ec2"]
    detail-type = ["EC2 Instance State-change Notification"]
  })
}

# Create an EventBridge target to trigger the Lambda function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.my_event_rule.name
  target_id = "my_lambda_target"
  arn       = aws_lambda_function.my_lambda.arn
}


# Grant EventBridge permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.my_lambda.function_name
  source_arn    = aws_cloudwatch_event_rule.my_event_rule.arn
}
