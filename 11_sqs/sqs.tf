resource "aws_sqs_queue" "TF_ORDER_QUEUE" {
  name                      = "order-processing-queue"

  # FIFO properties
  fifo_queue                  = true # Optional, only if we want to use FIFO
  content_based_deduplication = true # Optional, to enable automatic deduplication of messages

  # Optional parameters
  delay_seconds               = 0
  maximum_message_size        = 262144  # Maximum message size in bytes (256 KB)
  message_retention_seconds   = 345600  # Time in seconds to retain messages (default is 4 days)
  receive_message_wait_time_seconds = 0  # Short polling

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dead_letter_queue.arn
    maxReceiveCount     = 5
  })

  # Optionally, enable server-side encryption
  kms_master_key_id = "alias/aws/sqs" # Default AWS-managed key


  tags = {
    Environment = "dev"
    Application = "example-app"
  }
}

# Optional: Dead Letter Queue
resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "order-processing-dead-letter-queue"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Environment = "production"
    Application = "order-system"
  }
}

# Optional: grouping is applicable only for FIFO
# Example to send a message with MessageGroupId
resource "aws_sqs_queue" "message_group_sender" {
  queue_url = aws_sqs_queue.fifo_queue.url

  # Send a message with a specific MessageGroupId
  action "send_message" {
    message_group_id = "my-message-group"
    message_body     = "This is a test message in group 1"
  }
}




output "test_sqs_messages" {
  value = aws_sqs_queue.TF_ORDER_QUEUE.url
}


