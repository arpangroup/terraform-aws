# AWS Lambda
- [Automate zipping of Lambda code](README-lambda_automate_ziping_process)
- Runtime
- Architecture (x86_64 / arm64)
- Execution Role
- Lambda Layers
- [Triggers](README-lambda_trigger.md) (`API Gateway`, `ALB`, `CloudFront`, `CodeCommit`, `CloudWatch Log`, `EventBridge`, `S3`, `SQS`, `SNS`, `DynamoDB` etc...)
- Permissions
- [Destinations](README-lambda_destinations.md)
- [Environment Variables](README-lambda_automate_envs.md)
- VPC - Create Lambda Function in a specific VPC?
- Monitoring
- [Concurrency](README-lambda_concurrency.md)
- [Asynchronous Invocation](README-lambda_asynchronous_invocation)
- [Retry](README-lambda_retry.md)
- [AWS Lambda with Python vs Java](README-lambda_with_python_vs_java.md)
- [Secure API Gateway Requests with AWS Lambda Authorizer](README-lambda_authentication.md)


### Lambda Function [Best Practices](README-lambda_best_practices.md)

---


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
See [Automate zipping of Lambda code](README-lambda_automate_ziping_process)
````hcl
# Create Zip file locally
resource "null_resource" "ZIP_LAMBDA" {
  provisioner "local-exec" {
    command = "echo CurrentDirectory: %CD% && zip ./lambda_function.zip ./lambda_function.py"
  }
}
````

---

## AWS Principals for Lambda Invocation from other services

````hcl
# The aws_lambda_permission resource in Terraform is used to grant permissions to other AWS services or accounts to invoke an AWS Lambda function.
# Grant the S3 bucket permission to invoke the Lambda function
# principal:
resource "aws_lambda_permission" "allow_s3" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example.function_name
  principal     = "s3.amazonaws.com"  # Allows S3 to invoke the function. ["sns.amazonaws.com", "events.amazonaws.com", "logs.amazonaws.com", "cognito-idp.amazonaws.com", "apigateway.amazonaws.com"]
  source_arn    = aws_s3_bucket.example.arn # Optional: Restricts the permission to a specific resource. This ensures the Lambda function can only be invoked by specific events or entities.
#   source_account = "" # optional
}
````

This table lists common AWS services that can invoke a Lambda function and their corresponding principals.

| Principal                | Purpose                                          |
|--------------------------|--------------------------------------------------|
| `s3.amazonaws.com`       | Allow S3 to invoke the Lambda function.          |
| `sns.amazonaws.com`      | Allow SNS to invoke the Lambda function.         |
| `events.amazonaws.com`   | Allow EventBridge (CloudWatch Events) to invoke. |
| `logs.amazonaws.com`     | Allow CloudWatch Logs to invoke the function.    |
| `cognito-idp.amazonaws.com` | Allow Amazon Cognito triggers to invoke Lambda. |
| `apigateway.amazonaws.com` | Allow API Gateway to invoke the Lambda function. |



---

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


## FAQs
1. **How many maximum lambda function I can create in an account?** - 1,000 functions per region (default)
   - **Default Account-Level Concurrency Limit**: 1,000 concurrent executions per AWS region.
   - **Function-Level Concurrency Limits**: By default, Lambda functions share the account-level concurrency pool, meaning each function can potentially use all of the available concurrency
   - **Lambda deployment package size limits** (50 MB for direct uploads, 250 MB for S3 uploads).
   - **Lambda invocation payload size limits** (6 MB for synchronous invocations, 256 KB for asynchronous invocations).
2. **How to Autoscale LambdaFunction?** AWS Lambda automatically scales by design  to handle varying traffic loads without needing any manual intervention.
3. **How to ensure Lambda function can be execute with valid Authentication Header?** [answer](README-lambda_authentication.md)
4. **LambdaFunction in Java Vs Python performance comparison** [answer](README-lambda_with_python_vs_java.md)
5. Create a Lambda function which will run every day at 10am and check
   - if there is any new user created
   - If any additional permission added to an existing IAM Roles
   - If there is any GP2 based EBS volume in any account
   - Also notify the result