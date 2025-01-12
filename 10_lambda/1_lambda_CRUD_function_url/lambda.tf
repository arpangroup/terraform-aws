provider "aws" {
  region = "us-east-1"
}

# Step1: Create an IAM role for the Lambda function
resource "aws_iam_role" "TF_lambda_role" {
  name = "tf_lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Step2: Attach AWSLambdaBasicExecutionRole policy to above role
# This policy allow:
#   - Basic Lambda Execution: The policy ensures that the Lambda function can execute and manage its own runtime environment.
#   - Write Logs to Amazon CloudWatch Logs:
resource "aws_iam_role_policy_attachment" "lambda_basic_execution" {
  role       = aws_iam_role.TF_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# or by using "aws_iam_policy_attachment":
/*resource "aws_iam_policy_attachment" "lambda_policy" {
  name       = "lambda-policy-attach"
  roles      = [aws_iam_role.TF_lambda_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}*/


# Step3: Create the Lambda Function with above IAM Role
resource "aws_lambda_function" "TF_LAMBDA_EXAMPLE" {
  depends_on    = [null_resource.ZIP_LAMBDA]
  function_name = "tf_crud_lambda"
  role          = aws_iam_role.TF_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      ITEMS  = "{}"  # In-memory storage for items
    }
  }
}


# Lambda Function URL
resource "aws_lambda_function_url" "crud_lambda_url" {
  function_name      = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
  authorization_type = "NONE"
}

output "lambda_function_url" {
  value = aws_lambda_function_url.crud_lambda_url.function_url
}