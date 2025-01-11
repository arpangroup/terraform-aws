# Attach managed policy to allow Lambda function to access S3 bucket,
# because our lambda will read the object from S3
# "s3:Get*", "s3:List*", "s3:Describe*", "s3-object-lambda:Get*", "s3-object-lambda:List*"
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role       = aws_iam_role.TF_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# Optional: Allow Lambda function to access SQS if we want to use sqs as an event source
# ReceiveMessage, DeleteMessage, GetQueueAttributes, CreateLogGroup, CreateLogStream, PutLogEvents
resource "aws_iam_role_policy_attachment" "sqs_access" {
  role       = aws_iam_role.TF_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}


# Or, alternatively we can add inline policy to the IAM Role:
# Attach a policy to allow the Lambda function to read from S3
/*resource "aws_iam_role_policy" "s3_read_access" {
  role = aws_iam_role.TF_lambda_role.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.example_bucket.arn,
          "${aws_s3_bucket.example_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ]
        Resource = aws_sqs_queue.example_queue.arn
      }
    ]
  })
}*/


# Grant S3 permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
  principal     = "s3.amazonaws.com"                  # for EventBridge: "events.amazonaws.com"
  source_arn    = "arn:aws:s3:::tf-example-bucket123" # for EventBridge: <CLOUDWATCH_EVENT_BRIDGE_RULE_ARN>
}

