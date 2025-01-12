/*# Create an S3 bucket notification to trigger the Lambda function
resource "aws_s3_bucket_notification" "example" {
  bucket = "tf-example-bucket123"

  lambda_function {
    lambda_function_arn = aws_lambda_function.TF_LAMBDA_EXAMPLE.arn
    events              = ["s3:ObjectCreated:Put"] # ["s3:ObjectCreated:*"]

    #filter_prefix       = "uploads/"
    filter_suffix        = ".txt" # Optional: Trigger only for .txt files
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke # Mandatory, otherwise terraform will fail to create this resource
  ]

}

*/