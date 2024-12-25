# AWS Lambda
- [Automate zipping of Lambda code](README-automate_ziping_process.md)


## Create a Lambda Function
````hcl
# The Lambda Function
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

# Define IAM AssumeRole
resource "aws_iam_role" "TF_lambda_role" {
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

# Attach Policy to Above Role
resource "aws_iam_policy_attachment" "lambda_policy" {
   name       = "lambda-policy-attach"
   roles      = [aws_iam_role.TF_lambda_role.name]
   policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Just to get the Function URL, so that we can output the same
resource "aws_lambda_function_url" "my_lambda_url" {
   function_name      = aws_lambda_function.TF_LAMBDA_EXAMPLE.function_name
   authorization_type = "NONE" # Public access (change to "AWS_IAM" for IAM-based access control)
}

# Fetch the current region
data "aws_region" "current" {}

output "lambda_curl" {
   value = <<-EOT
    ..............................................
    curl -X POST https://${aws_lambda_function_url.my_lambda_url.url_id}.lambda-url.${data.aws_region.current.name}.on.aws \
      -H "Content-Type: application/json" \
      -d '{"key1": "value1", "key2": "value2"}'
    ..............................................
  EOT
}
````
### Optional: Automate Zip Creation using Terraform
See [Automate zipping of Lambda code](README-automate_ziping_process.md)
````hcl
# Create Zip file locally
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_function.py"
  }
}
````


1. How many maximum lambda function I can create in an account?
2. What is concurrency?
3. Create a Lambda function which will run every day at 10am and check 
   - if there is any new user created
   - If any additional permission added to an existing IAM Roles
   - If there is any GP2 based EBS volume in any account
   - Also notify the result
4. XXX

## Output Details of an aws_lambda_function 
````hcl
output "function_details" {
  value = aws_lambda_function.TF_LAMBDA_EXAMPLE
}
````
Output:
````hcl
 {
  "architectures" = tolist([
    "x86_64",
  ])
  "arn" = "arn:aws:lambda:us-east-1:491085411576:function:tf_example_lambda"
  "code_sha256" = "aYzhqQ3RnT8PwmtxKmzLUL66eWAx62cuJEk5jV3yiBk="
  "code_signing_config_arn" = ""
  "dead_letter_config" = tolist([])
  "description" = ""
  "environment" = tolist([
    {
      "variables" = tomap({
        "KEY" = "value"
      })
    },
  ])
  "ephemeral_storage" = tolist([
    {
      "size" = 512
    },
  ])
  "file_system_config" = tolist([])
  "filename" = "lambda_function.zip"
  "function_name" = "tf_example_lambda"
  "handler" = "lambda_function.lambda_handler"
  "id" = "tf_example_lambda"
  "image_config" = tolist([])
  "image_uri" = ""
  "invoke_arn" = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:491085411576:function:tf_example_lambda/invocations"
  "kms_key_arn" = ""
  "last_modified" = "2024-12-25T14:48:21.221+0000"
  "layers" = tolist(null) /* of string */
  "logging_config" = tolist([
    {
      "application_log_level" = ""
      "log_format" = "Text"
      "log_group" = "/aws/lambda/tf_example_lambda"
      "system_log_level" = ""
    },
  ])
  "memory_size" = 128
  "package_type" = "Zip"
  "publish" = false
  "qualified_arn" = "arn:aws:lambda:us-east-1:491085411576:function:tf_example_lambda:$LATEST"
  "qualified_invoke_arn" = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/arn:aws:lambda:us-east-1:491085411576:function:tf_example_lambda:$LATEST/invocations"
  "replace_security_groups_on_destroy" = tobool(null)
  "replacement_security_group_ids" = toset(null) /* of string */
  "reserved_concurrent_executions" = -1
  "role" = "arn:aws:iam::491085411576:role/lambda-execution-role"
  "runtime" = "python3.9"
  "s3_bucket" = tostring(null)
  "s3_key" = tostring(null)
  "s3_object_version" = tostring(null)
  "signing_job_arn" = ""
  "signing_profile_version_arn" = ""
  "skip_destroy" = false
  "snap_start" = tolist([])
  "source_code_hash" = ""
  "source_code_size" = 639
  "tags" = tomap(null) /* of string */
  "tags_all" = tomap({})
  "timeout" = 3
  "timeouts" = null /* object */
  "tracing_config" = tolist([
    {
      "mode" = "PassThrough"
    },
  ])
  "version" = "$LATEST"
  "vpc_config" = tolist([])
}
````