# Attach policy to allow Lambda function to access S3 bucket
# Because our lambda will read the object from S3
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role       = aws_iam_role.TF_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}


# Or, alternatively we can use:
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
      }
    ]
  })
}*/