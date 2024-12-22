# IAM Role for EC2
resource "aws_iam_role" "TF_EC2_LOGGING_ROLE" {
  name               = "tf-ec2-logging-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { Service = "ec2.amazonaws.com" }
        Action    = "sts:AssumeRole"
      },
    ]
  })
}

# Attach Policy to Allow Logging
resource "aws_iam_policy" "TF_LOGGING_POLICY" {
  name        = "TF_CloudWatchLoggingPolicy"
  description = "Policy for EC2 to send logs to CloudWatch"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "*"
      },
    ]
  })
}


resource "aws_iam_role_policy_attachment" "TF_attach_logging_policy" {
  role       = aws_iam_role.TF_EC2_LOGGING_ROLE.name
  policy_arn = aws_iam_policy.TF_LOGGING_POLICY.arn
}

# EC2 Instance Profile
resource "aws_iam_instance_profile" "TF_ec2_instance_profile" {
  name = "tf-ec2-instance-profile"
  role = aws_iam_role.TF_EC2_LOGGING_ROLE.name
}
