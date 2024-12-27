resource "aws_s3_bucket" "input_bucket" {
  bucket = "data-input-bucket"
}

resource "aws_sqs_queue" "main_queue" {
  name                      = "main-queue"
  message_retention_seconds = 86400

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })
}

resource "aws_sqs_queue" "dlq" {
  name = "dlq-queue"
}

resource "aws_cloudwatch_event_rule" "scheduler_rule" {
  name        = "scheduler-rule"
  schedule_expression = "rate(1 day)"
}

resource "aws_cloudwatch_event_target" "scheduler_target" {
  rule      = aws_cloudwatch_event_rule.scheduler_rule.name
  arn       = aws_lambda_function.reader_lambda.arn
}

resource "aws_lambda_permission" "allow_scheduler" {
  statement_id  = "AllowSchedulerInvocation"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reader_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.scheduler_rule.arn
}
