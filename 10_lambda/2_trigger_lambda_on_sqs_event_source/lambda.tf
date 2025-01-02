# Create a Lambda function
resource "aws_lambda_function" "TF_example_lambda" {
  function_name = "tf_example_lambda"
  role          = aws_iam_role.TF_lambda_exec_role.arn
  runtime       = "python3.9"
  handler       = "lambda_function.lambda_handler"

  filename         = "./lambda_function.zip"
  source_code_hash = filebase64sha256("./lambda_function.zip")
  depends_on       = [null_resource.ZIP_LAMBDA]
}

# The aws_lambda_permission resource in Terraform is used to grant permissions to other AWS services or accounts to invoke an AWS Lambda function.
# Grant the S3 bucket permission to invoke the Lambda function
# principal:
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.TF_example.function_name
  principal     = "s3.amazonaws.com"  # Allows S3 to invoke the function. ["sns.amazonaws.com", "events.amazonaws.com", "logs.amazonaws.com", "cognito-idp.amazonaws.com", "apigateway.amazonaws.com"]
  source_arn    = aws_s3_bucket.example.arn # Optional: Restricts the permission to a specific resource. This ensures the Lambda function can only be invoked by specific events or entities.
  #   source_account = "" # optional
}

##################################################################
##################  IAM PERMISSIONS  #############################
##################################################################

# Create an IAM role for the Lambda function
resource "aws_iam_role" "TF_lambda_exec_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "lambda.amazonaws.com"
      }
    }]
  })
}

# Attach policy to allow Lambda function to write logs to CloudWatch
resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.TF_lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}



##################################################################
################  AUTOMATE ZIPPING Python FILE  ##################
##################################################################

# Create Zip file locally
# zip ./lambda_function.zip ./lambda_function.py
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_function.py"
  }
}
