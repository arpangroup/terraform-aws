/*# Step 4: Create an EventBridge rule to capture S3 PutObject events
resource "aws_cloudwatch_event_rule" "s3_put_object_rule" {
  name        = "s3-put-object-rule"
  description = "Trigger Lambda when an object is uploaded to S3"

  event_pattern = jsonencode({
    source      = ["aws.s3"]
    detail_type = ["AWS API Call via CloudTrail"]
    detail = {
      eventSource = ["s3.amazonaws.com"]
      eventName   = ["PutObject"]
      requestParameters = {
        bucketName = [aws_s3_bucket.example_bucket.bucket]
      }
    }
  })
}

# Step 5: Add the Lambda function as a target for the EventBridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.s3_put_object_rule.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.example_lambda.arn
}

# Step 6: Grant EventBridge permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.s3_put_object_rule.arn
}*/