resource "aws_lambda_function" "processor_lambda" {
  function_name = "processor-lambda"
  runtime       = "python3.9"
  handler       = "processor.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  s3_bucket     = "your-lambda-code-bucket"
  s3_key        = "processor-lambda.zip"
}
