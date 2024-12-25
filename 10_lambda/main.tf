resource "aws_lambda_function" "TF_LAMBDA_EXAMPLE" {
  depends_on    = [null_resource.zip_lambda]
  function_name = "tf_example_lambda"
  role          = aws_iam_role.TF_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      KEY = "value"
    }
  }
}

