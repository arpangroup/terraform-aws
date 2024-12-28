# Step3: Create IAM role for Lambda execution (if not already created)
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}


# Step4: Create IAM role for EventBridge to invoke Lambda function
resource "aws_iam_role" "lambda_exec" {
  name               = "lambda_exec_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}

# Step5: Create IAM role for EventBridge to invoke Lambda
resource "aws_iam_role" "eventbridge_role" {
  name               = "eventbridge_lambda_invoke_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Effect = "Allow"
        Sid    = ""
      },
    ]
  })
}


# Step6: Create Lambda permission to allow EventBridge to invoke it
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  principal     = "events.amazonaws.com"
  function_name = aws_lambda_function.my_lambda.function_name
  source_arn    = aws_eventbridge_schedule.cron_schedule.arn
}


