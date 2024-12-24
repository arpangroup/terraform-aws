# IAM Role for EC2
resource "aws_iam_role" "TF_EC2_LOGGING_ROLE" {
  name               = "tf-ec2-cloudwatch-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach Policy to Allow Logging
resource "aws_iam_policy" "TF_LOGGING_POLICY" {
  name        = "TF_EC2CloudWatchLoggingRole"
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


# An instance profile allows an EC2 instance to securely access AWS
# services (e.g., S3, CloudWatch) without hardcoding AWS credentials in the instance.
resource "aws_iam_role_policy_attachment" "attach_logging_policy" {
  role       = aws_iam_role.TF_EC2_LOGGING_ROLE.name
  policy_arn = aws_iam_policy.TF_LOGGING_POLICY.arn
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "tf-ec2-instance-profile"
  role = aws_iam_role.TF_EC2_LOGGING_ROLE.name
}

# resource "aws_instance" "ec2_instance" {
#   .....
#   iam_instance_profile        = aws_iam_instance_profile.ec2_instance_profile.name
#   ....
# }