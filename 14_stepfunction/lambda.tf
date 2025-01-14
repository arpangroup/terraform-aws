# Lambda Functions for Each Step
resource "aws_lambda_function" "validate_order" {
  filename      = "${path.module}/lambda_codes/archives/validate_order.zip"
  function_name = "ValidateOrder"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "validate_order.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [null_resource.ZIP_LAMBDA]
#   source_code_hash = filebase64sha256("validate_order.zip")
}

resource "aws_lambda_function" "process_payment" {
  filename      = "${path.module}/lambda_codes/archives/process_payment.zip"
  function_name = "ProcessPayment"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "process_payment.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [null_resource.ZIP_LAMBDA]
#   source_code_hash = filebase64sha256("process_payment.zip")
}

resource "aws_lambda_function" "prepare_shipment" {
  filename      = "${path.module}/lambda_codes/archives/prepare_shipment.zip"
  function_name = "PrepareShipment"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "prepare_shipment.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [null_resource.ZIP_LAMBDA]
#   source_code_hash = filebase64sha256("prepare_shipment.zip")
}

resource "aws_lambda_function" "notify_customer" {
  filename      = "${path.module}/lambda_codes/archives/notify_customer.zip"
  function_name = "NotifyCustomer"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "notify_customer.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [null_resource.ZIP_LAMBDA]
#   source_code_hash = filebase64sha256("notify_customer.zip")
}

resource "aws_lambda_function" "handle_error" {
  filename      = "${path.module}/lambda_codes/archives/handle_error.zip"
  function_name = "HandleError"
  role          = aws_iam_role.lambda_exec_role.arn
  handler       = "handle_error.lambda_handler"
  runtime       = "python3.9"
  depends_on    = [null_resource.ZIP_LAMBDA]
#   source_code_hash = filebase64sha256("handle_error.zip")
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