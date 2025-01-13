# Fetch the current region
data "aws_region" "current" {}

resource "aws_lambda_function" "TF_LAMBDA_EXAMPLE" {
  depends_on    = [null_resource.ZIP_LAMBDA]
  function_name = "tf_example_lambda"
  role          = aws_iam_role.TF_lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.9"
  filename      = "lambda_function.zip"

  environment {
    variables = {
      KEY = "value"
    }
  }
}

resource "aws_lambda_function_url" "my_lambda_url" {
  function_name      = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
  authorization_type = "NONE" # Public access (change to "AWS_IAM" for IAM-based access control)
}

# Fetch the current region
data "aws_region" "current" {}

output "function_details" {
  value = aws_lambda_function.TF_LAMBDA_EXAMPLE
}

output "lambda_curl" {
  value = <<-EOT
    ..............................................
    curl -X POST https://${aws_lambda_function_url.my_lambda_url.url_id}.lambda-url.${data.aws_region.current.name}.on.aws \
      -H "Content-Type: application/json" \
      -d '{"key1": "value1", "key2": "value2"}'
    ..............................................
  EOT
}


# Create Zip file locally
# zip ./lambda_function.zip ./lambda_retry_sync.py
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_function.py"
  }
}