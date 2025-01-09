/*provider "aws" {
  region = "us-east-1"
}

# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-s3-bucket"
}

# Create an S3 bucket notification to trigger the Lambda function
resource "aws_s3_bucket_notification" "example" {
  bucket = aws_s3_bucket.example.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.TF_example_lambda.arn
    events              = ["s3:ObjectCreated:Put"]

    filter_suffix = ".txt" # Optional: Trigger only for .txt files
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}

*/