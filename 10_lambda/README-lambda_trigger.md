#  AWS Lambda Trigger 

### Common AWS Lambda Triggers
1. **S3**: Trigger a Lambda function on object creation, deletion, or modification events in an S3 bucket.
2. **DynamoDB**: Trigger a function when data is added, updated, or removed in a DynamoDB table (via streams).
3. **SQS**: Process messages from an SQS queue.
4. **SNS**: Trigger a function when a message is published to an SNS topic.
5. **EventBridge (CloudWatch Events)**: Trigger functions based on scheduled events or specific AWS service events.
6. **Kinesis**: Process streaming data from a Kinesis data stream.
7. **API Gateway**: Trigger a function in response to HTTP requests via REST or WebSocket APIs.
8. **AWS Step Functions**: Trigger Lambda functions as part of a workflow.
9. **Amazon Cognito**: Trigger a function during authentication or user pool events (e.g., sign-up, pre-token generation).
10. **AWS IoT**: Trigger Lambda functions based on IoT rules.
11. **RDS Proxy**: Trigger functions with database events.
12. **Third-party sources**: Trigger functions using services like GitHub, Slack, or custom applications integrated via EventBridge.

Example: S3 Trigger
````hcl
resource "aws_lambda_function" "my_lambda" {
 .......
}

resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket-name"
}

resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.my_lambda.arn
    events              = ["s3:ObjectCreated:*"]
  }
}

resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = aws_s3_bucket.my_bucket.arn
}

````