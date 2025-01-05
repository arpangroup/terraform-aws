#  AWS Lambda Trigger 

### Common AWS Lambda Triggers
1. **S3**: Trigger a Lambda function on object creation, deletion, or modification events in an S3 bucket.
2. **DynamoDB**: Trigger a function when data is added, updated, or removed in a DynamoDB table (via streams).
3. **SQS**: Process messages from an SQS queue.
4. **SNS**: Trigger a function when a message is published to an SNS topic.
5. **EventBridge (CloudWatch Events)**: Trigger functions based on scheduled events or specific AWS service events.
6. **Kinesis**: Process streaming data from a Kinesis data stream.
7. **API Gateway**: Trigger a function in response to HTTP requests via REST or WebSocket APIs.
8. **AWS Step Functions**: Trigger Lambda functions as part of a workflow.
9. **Amazon Cognito**: Trigger a function during authentication or user pool events (e.g., sign-up, pre-token generation).
10. **AWS IoT**: Trigger Lambda functions based on IoT rules.
11. **RDS Proxy**: Trigger functions with database events.
12. **Third-party sources**: Trigger functions using services like GitHub, Slack, or custom applications integrated via EventBridge.

---

## Example1: Trigger Lambda Function from S3
````hcl
resource "aws_lambda_function" "example_lambda" {
  ....
}

# The aws_lambda_permission resource in Terraform is used to grant permissions to other AWS services or accounts to invoke an AWS Lambda function.
# Grant the S3 bucket permission to invoke the Lambda function
resource "aws_lambda_permission" "allow_s3_invoke" {
  statement_id  = "AllowS3Invoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_exec_role.function_name
  principal     = "s3.amazonaws.com"  # Allows S3 to invoke the function. ["sns.amazonaws.com", "events.amazonaws.com", "logs.amazonaws.com", "cognito-idp.amazonaws.com", "apigateway.amazonaws.com"]
  source_arn    = aws_s3_bucket.example.arn # Optional: Restricts the permission to a specific resource. This ensures the Lambda function can only be invoked by specific events or entities.
  #   source_account = "" # optional
}

##################################################################
######## ASSUME ROLE PERMISSION FOR LAMBDA EXECUTION #############
##################################################################
# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
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
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}




##################################################################
############################# S3 #################################
##################################################################
# Create an S3 bucket
resource "aws_s3_bucket" "example" {
  bucket = "example-s3-bucket"
  acl    = "private"
}

# Create an S3 bucket notification to trigger the Lambda function
resource "aws_s3_bucket_notification" "s3_lambda_trigger" {
  bucket = aws_s3_bucket.my_bucket.id

  lambda_function {
    lambda_function_arn = aws_lambda_function.example_lambda.arn
    events              = ["s3:ObjectCreated:*"]

    filter_suffix = ".txt" # Optional: Trigger only for .txt files
  }

  depends_on = [
    aws_lambda_permission.allow_s3_invoke
  ]
}
````

---

## Example2: Trigger Lambda Function from an SQS (Event Source Mapping):
````hcl
resource "aws_lambda_function" "example_lambda" {
  ....
}
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.example_queue.arn
  function_name    = aws_lambda_function.example_lambda.arn
  batch_size       = 10
  enabled          = true
}

##################################################################
######## ASSUME ROLE PERMISSION FOR LAMBDA EXECUTION #############
##################################################################
# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
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
resource "aws_iam_policy_attachment" "lambda_basic_execution" {
  name       = "lambda-basic-execution-attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_policy" "sqs_access_policy" {
  name = "sqs-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Effect   = "Allow",
        Resource = aws_sqs_queue.example_queue.arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "sqs_access_policy_attachment" {
  name       = "sqs-access-policy-attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}

````

Merge IAM:
````hcl
resource "aws_iam_role" "lambda_execution_role" {
  name = "lambda-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_policy" {
  name   = "lambda-policy"
  role   = aws_iam_role.lambda_execution_role.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      # Basic Lambda execution permissions
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:logs:*:*:*"
      },
      # SQS access permissions
      {
        Action = [
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes"
        ],
        Effect   = "Allow",
        Resource = aws_sqs_queue.example_queue.arn
      }
    ]
  })
}

````
Updated Usage in Lambda Function:
````hcl
resource "aws_lambda_function" "example_lambda" {
  filename         = "lambda_function.zip"
  function_name    = "example-lambda"
  role             = aws_iam_role.lambda_execution_role.arn
  handler          = "index.handler"
  runtime          = "nodejs18.x"
  source_code_hash = filebase64sha256("lambda_function.zip")
}
````


## Example3: Trigger Lambda Function from DynamoDB

## Example4: Trigger Lambda Function from EventBridge

## Example5: Trigger Lambda Function from API Gateway

## Example6: Trigger Lambda Function from Step Function