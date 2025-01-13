# Create the main SQS queue
resource "aws_sqs_queue" "main_queue" {
  name                      = "main-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  visibility_timeout_seconds = 30    # Adjust based on your Lambda function's execution time

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3 # Number of retries before sending to DLQ
  })

  tags = {
    Environment = "production"
  }
}

# Create the Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                      = "dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Environment = "production"
  }
}

# Create the event source mapping to trigger the Lambda function
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.sqs_processor.arn
  batch_size       = 10
}