resource "aws_lambda_function" "reader_lambda" {
  function_name = "tf-reader-lambda"
  runtime       = "python3.9"
  handler       = "reader.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  s3_bucket     = "your-lambda-code-bucket"
  s3_key        = "reader-lambda.zip"
  environment {
    variables = {
      SQS_QUEUE_URL = aws_sqs_queue.main_queue.id
    }
  }
}

