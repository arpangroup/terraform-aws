# Attach policy to allow Lambda function to access S3 bucket, because our lambda will read the object from S3
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


# Grant S3 permission to invoke the Lambda function
/*resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowExecutionFromS3"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
  principal     = "s3.amazonaws.com"
  source_arn    = "arn:aws:s3:::tf-example-bucket123"
}*/