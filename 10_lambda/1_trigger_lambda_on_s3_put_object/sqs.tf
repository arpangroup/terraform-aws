# Create SQS
resource "aws_sqs_queue" "TF_example_queue" {
  name = "tf-example-queue"
}

# Create the SQS event source mapping
resource "aws_lambda_event_source_mapping" "example_mapping" {
  event_source_arn = aws_sqs_queue.TF_example_queue.arn
  function_name    = aws_lambda_function.TF_LAMBDA_EXAMPLE.arn
  enabled          = true
  batch_size       = 10 # Number of messages to process at once
}