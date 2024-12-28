variable "bucket_name" {
  default = "tf-example-bucket123"
}

resource "aws_sqs_queue" "TF_ORDER_QUEUE" {
  name                      = "order-processing-queue"
  delay_seconds             = 0
  max_message_size          = 262144 # 256 KB
  message_retention_seconds = 345600 # 4 days
  receive_wait_time_seconds = 10

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

resource "aws_sqs_queue" "dead_letter_queue" {
  name                      = "order-processing-dead-letter-queue"
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Environment = "production"
    Application = "order-system"
  }
}

## Just for Testing:
/*output "test_sqs_messages" {
  value = aws_sqs_queue.TF_ORDER_QUEUE.url
}

resource "null_resource" "push_messages" {
  depends_on = [aws_sqs_queue.TF_ORDER_QUEUE]

  provisioner "local-exec" {
    command = <<EOT
      aws sqs send-message-batch \\
        --queue-url https://sqs.us-west-2.amazonaws.com/123456789012/order-processing-queue \\
        --entries '[{"Id":"1","MessageBody":"{\"orderId\": \"12345\", \"status\": \"created\"}"},
                    {"Id":"2","MessageBody":"{\"orderId\": \"67890\", \"status\": \"pending\"}"},
                    {"Id":"3","MessageBody":"{\"orderId\": \"54321\", \"status\": \"shipped\""}]'
    EOT
  }
}*/
