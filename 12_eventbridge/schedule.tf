# 1. Create the EventBridge Scheduler rule
resource "aws_eventbridge_schedule" "cron_schedule" {
  name              = "my-cron-schedule"
  description       = "A cron schedule to trigger every day at 12:00 UTC"
  schedule_expression = "cron(0 12 * * ? *)"  # Run at 12:00 UTC every day

  target {
    arn = aws_lambda_function.my_lambda.arn  # Lambda function ARN as the target
    role_arn = aws_iam_role.lambda_exec.arn  # IAM role ARN with permission to invoke Lambda
  }
}

# 2. Create the Lambda function (target for the cron job)
resource "aws_lambda_function" "my_lambda" {
  filename         = "lambda.zip"          # Path to your Lambda deployment package
  function_name    = "my_lambda_function"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs14.x"
}

