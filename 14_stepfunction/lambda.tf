# Lambda Functions for Each Step
resource "aws_lambda_function" "validate_order" {
  filename      = "validate_order.zip"
  function_name = "ValidateOrder"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("validate_order.zip")
}

resource "aws_lambda_function" "process_payment" {
  filename      = "process_payment.zip"
  function_name = "ProcessPayment"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("process_payment.zip")
}

resource "aws_lambda_function" "prepare_shipment" {
  filename      = "prepare_shipment.zip"
  function_name = "PrepareShipment"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("prepare_shipment.zip")
}

resource "aws_lambda_function" "notify_customer" {
  filename      = "notify_customer.zip"
  function_name = "NotifyCustomer"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("notify_customer.zip")
}

resource "aws_lambda_function" "handle_error" {
  filename      = "handle_error.zip"
  function_name = "HandleError"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "index.handler"
  runtime       = "nodejs14.x"

  source_code_hash = filebase64sha256("handle_error.zip")
}






# IAM Role for Lambda Execution
resource "aws_iam_role" "lambda_exec_role" {
  name = "LambdaExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}