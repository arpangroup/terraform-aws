provider "aws" {
  region = "us-east-1"  # Specify your region
}

# Create SNS Topic
resource "aws_sns_topic" "example" {
  name = "example-topic"
}

# Allow SNS to send messages to SQS
resource "aws_sqs_queue_policy" "example" {
  queue_url = aws_sqs_queue.example.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "SQS:SendMessage"
        Effect    = "Allow"
        Resource  = aws_sqs_queue.example.arn
        Principal = "*"
        Condition = {
          ArnEquals = {
            "aws:SourceArn" = aws_sns_topic.example.arn
          }
        }
      }
    ]
  })
}

# Subscribe SQS Queue to SNS Topic
resource "aws_sns_topic_subscription" "queue_subscription" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.example.arn
}

# Subscribe an email to the SNS Topic
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.example.arn
  protocol  = "email"
  endpoint  = "your-email@example.com"  # Replace with your email address
}

# Optionally, create a Lambda function to customize email content (if needed)
resource "aws_lambda_function" "example" {
  function_name = "example-email-customizer"

  # Lambda configuration (for demonstration purposes, you can create a custom function to process the message)
  runtime = "nodejs14.x"
  role    = aws_iam_role.lambda_role.arn
  handler = "index.handler"

  # Your custom Lambda code (replace with actual code if needed)
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
}

# Create IAM role for Lambda function (if you want to customize email content via Lambda)
resource "aws_iam_role" "lambda_role" {
  name = "example-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Allow Lambda to interact with SNS
resource "aws_iam_role_policy" "lambda_sns_policy" {
  name = "lambda-sns-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sns:Publish"
        Effect    = "Allow"
        Resource  = aws_sns_topic.example.arn
      }
    ]
  })
}