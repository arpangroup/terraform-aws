
resource "aws_lambda_function" "writer_lambda" {
  function_name = "writer-lambda"
  runtime       = "python3.9"
  handler       = "writer.lambda_handler"
  role          = aws_iam_role.lambda_execution_role.arn
  s3_bucket     = "your-lambda-code-bucket"
  s3_key        = "writer-lambda.zip"
  environment {
    variables = {
      DYNAMODB_TABLE = aws_dynamodb_table.results_table.name
    }
  }
}