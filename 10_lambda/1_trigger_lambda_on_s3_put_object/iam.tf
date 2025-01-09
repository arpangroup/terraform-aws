# Attach policy to allow Lambda function to access S3 bucket
# Because our lambda will read the object from S3
resource "aws_iam_role_policy_attachment" "s3_read_only_access" {
  role       = aws_iam_role.TF_lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}