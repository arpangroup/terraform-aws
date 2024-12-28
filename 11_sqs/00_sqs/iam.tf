/*resource "aws_iam_policy" "sqs_permissions" {
  name        = "SQSPermissionsPolicy"
  description = "IAM policy for SQS queue creation and management"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "sqs:CreateQueue",
          "sqs:TagQueue",
          "sqs:SetQueueAttributes"
        ],
        Resource = "arn:aws:sqs:us-east-1:*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "attach_sqs_policy" {
  user       = "tf-module-pave"
  policy_arn = aws_iam_policy.sqs_permissions.arn
}*/