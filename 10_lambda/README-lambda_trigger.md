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

# AWS Lambda Event Sources

| **Event Source**               | **Event**                                                                 | **Use Case**                                                                 | **Terraform Resource**                                                                 |
|--------------------------------|---------------------------------------------------------------------------|------------------------------------------------------------------------------|---------------------------------------------------------------------------------------|
| **Amazon S3**                  | Object creation, deletion, or restoration in an S3 bucket.               | Process files uploaded to S3 (e.g., image resizing, data transformation).    | `aws_s3_bucket_notification`.                                                        |
| **Amazon DynamoDB**            | Changes to a DynamoDB table (inserts, updates, deletes).                 | React to changes in DynamoDB data (e.g., update a search index).             | `aws_lambda_event_source_mapping` (with DynamoDB stream ARN).                         |
| **Amazon SQS**                 | New messages in an SQS queue.                                            | Process messages from a queue (e.g., background jobs, task processing).      | `aws_lambda_event_source_mapping` (with SQS queue ARN).                               |
| **Amazon Kinesis Data Streams**| New records in a Kinesis data stream.                                     | Process real-time data streams (e.g., log processing, analytics).            | `aws_lambda_event_source_mapping` (with Kinesis stream ARN).                          |
| **Amazon Kinesis Data Firehose**| Data delivery to a Kinesis Data Firehose stream.                         | Transform or process data before delivering it to a destination (e.g., S3). | Configured via Kinesis Data Firehose delivery stream settings.                        |
| **Amazon EventBridge**         | Custom events or scheduled events.                                       | Trigger Lambda functions based on custom events or cron-like schedules.      | `aws_cloudwatch_event_rule` and `aws_cloudwatch_event_target`.                        |
| **Amazon API Gateway**         | HTTP requests to an API Gateway endpoint.                                | Build serverless APIs (e.g., RESTful APIs, microservices).                   | `aws_api_gateway_rest_api`, `aws_api_gateway_integration`.                            |
| **Amazon SNS**                 | New messages published to an SNS topic.                                  | Fan-out notifications to multiple subscribers (e.g., email, SMS).            | `aws_sns_topic_subscription`.                                                         |
| **Amazon Cognito**             | User pool events (e.g., user sign-up, authentication).                   | Customize authentication workflows (e.g., send welcome emails).              | Configured via Cognito triggers.                                                      |
| **AWS Step Functions**         | State machine execution events.                                          | Orchestrate workflows using Lambda functions.                                | `aws_sfn_state_machine`.                                                              |
| **Amazon MQ**                  | Messages in an Amazon MQ queue.                                          | Process messages from a message broker.                                      | Configured via Amazon MQ event source mapping.                                        |
| **Amazon MSK**                 | New records in a Kafka topic.                                            | Process real-time data from Kafka topics.                                    | `aws_lambda_event_source_mapping` (with MSK cluster ARN).                             |
| **Amazon RDS**                 | Database events (e.g., inserts, updates, deletes) via RDS Proxy.         | React to database changes (e.g., audit logging, data synchronization).       | Configured via RDS Proxy or custom triggers.                                          |
| **AWS IoT Core**               | IoT device messages or rule actions.                                     | Process IoT device data (e.g., sensor data, device management).              | `aws_iot_topic_rule`.                                                                 |
| **AWS CodeCommit**             | Code repository events (e.g., push, pull request).                       | Automate CI/CD pipelines (e.g., run tests, deploy code).                     | Configured via CodeCommit triggers.                                                   |
| **AWS CloudFront**             | Viewer request/response or origin request/response events.               | Customize CDN behavior (e.g., A/B testing, request filtering).               | Configured via CloudFront Lambda@Edge.                                                |
| **AWS Config**                 | Configuration changes or compliance violations.                          | Enforce compliance rules or automate remediation.                            | Configured via AWS Config rules.                                                      |
| **AWS CloudTrail**             | API calls recorded by CloudTrail.                                        | Monitor and respond to API activity (e.g., security audits).                 | Configured via EventBridge or custom triggers.                                        |
| **AWS Batch**                  | Job state changes (e.g., job submitted, completed).                      | Automate batch job processing (e.g., data processing, ETL).                  | Configured via AWS Batch event rules.                                                 |
| **AWS AppSync**                | GraphQL API requests or mutations.                                       | Build serverless GraphQL APIs with custom resolvers.                         | `aws_appsync_resolver`.                                                               |
| **AWS Lex**                    | Chatbot interactions.                                                    | Build conversational interfaces (e.g., customer support bots).               | Configured via Lex bot triggers.                                                      |
| **AWS SES**                    | Incoming emails or email delivery events.                                | Process incoming emails or automate email workflows.                         | Configured via SES rules.                                                             |
| **AWS CloudWatch Logs**        | Log data matching a filter pattern.                                      | Process and analyze log data (e.g., error detection, alerting).              | `aws_cloudwatch_log_subscription_filter`.                                             |
| **AWS ECS**                    | Task state changes (e.g., task started, stopped).                        | Automate container orchestration (e.g., scaling, monitoring).                | Configured via EventBridge or custom triggers.                                        |
| **AWS Fargate**                | Task state changes in Fargate.                                           | Automate serverless container workflows.                                     | Configured via EventBridge or custom triggers.                                        |

---

## Example1: Trigger Lambda Function from S3
````hcl
resource "aws_lambda_function" "example_lambda" {
  function_name = "s3-trigger-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Replace with your preferred runtime

  # Use a placeholder code for the Lambda function
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.my_bucket.bucket
    }
  }
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

# Attach Policies to the IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = ["s3:GetObject", "s3:ListBucket"]
        Effect   = "Allow"
        Resource = [aws_s3_bucket.my_bucket.arn, "${aws_s3_bucket.my_bucket.arn}/*"]
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to allow Lambda function to write logs to CloudWatch
/*resource "aws_iam_role_policy_attachment" "lambda_logging" {
  role       = aws_iam_role.lambda_exec_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}*/

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

# Output the Bucket Name and Lambda Function Name
output "bucket_name" {
  value = aws_s3_bucket.my_bucket.bucket
}

output "lambda_function_name" {
  value = aws_lambda_function.example_lambda.function_name
}
````

---

## Example2: Trigger Lambda Function from an SQS (Event Source Mapping):
To trigger an AWS Lambda function from an Amazon SQS (Simple Queue Service) queue, you need to:
1. Create an SQS Queue: The queue where messages will be sent.
2. Create a Lambda Function: The function that will process messages from the SQS queue.
3. **Grant SQS Permission to Invoke the Lambda Function**: Allow the SQS queue to trigger the Lambda function.
4. **Configure the Lambda Function to Poll the SQS Queue**: Set up the Lambda function's event source mapping to poll the SQS queue for messages.
````hcl
resource "aws_lambda_function" "example_lambda" {
  ....
}

# Grant SQS Permission to Invoke the Lambda Function
resource "aws_lambda_event_source_mapping" "sqs_trigger" {
  event_source_arn = aws_sqs_queue.example_queue.arn
  function_name    = aws_lambda_function.example_lambda.arn
  batch_size       = 10 # Number of messages to process at a time
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

resource "aws_iam_policy" "sqs_access_policy" {
  name = "sqs-access-policy"
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:GetQueueAttributes"],
        Effect   = "Allow",
        Resource = aws_sqs_queue.example_queue.arn
      },
      {
        Action = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

/*resource "aws_iam_policy_attachment" "sqs_access_policy_attachment" {
  name       = "sqs-access-policy-attachment"
  roles      = [aws_iam_role.lambda_execution_role.name]
  policy_arn = aws_iam_policy.sqs_access_policy.arn
}*/

output "sqs_queue_url" {
  value = aws_sqs_queue.example_queue.url
}
output "lambda_function_name" {
  value = aws_lambda_function.example_lambda.function_name
}
````

---

## Example3: Trigger Lambda Function from DynamoDB
To trigger an AWS Lambda function from an Amazon DynamoDB table, you need to:
1. Create a DynamoDB Table: The table where data changes (inserts, updates, deletes) will occur.
2. Create a Lambda Function: The function that will process DynamoDB stream events.
3. Enable DynamoDB Streams: DynamoDB streams capture changes to the table and send them to the Lambda function.
4. Grant DynamoDB Permission to Invoke the Lambda Function: Allow DynamoDB to trigger the Lambda function when changes occur.
5. Configure the Lambda Function to Process DynamoDB Stream Events: Set up the Lambda function's event source mapping to process DynamoDB stream records.

````hcl
# 1. Create a DynamoDB Table
resource "aws_dynamodb_table" "example_table" {
  name           = "example-table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }

  # Enable DynamoDB Streams
  stream_enabled   = true
  stream_view_type = "NEW_AND_OLD_IMAGES" # Capture both new and old images of the item
}

# 2. Create an IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Attach Policies to the IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "dynamodb:GetRecords",
          "dynamodb:GetShardIterator",
          "dynamodb:DescribeStream",
          "dynamodb:ListStreams"
        ]
        Effect   = "Allow"
        Resource = aws_dynamodb_table.example_table.stream_arn
      },
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 4. Create a Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "dynamodb-trigger-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Replace with your preferred runtime

  # Use a placeholder code for the Lambda function
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

# 5. Grant DynamoDB Permission to Invoke the Lambda Function
resource "aws_lambda_event_source_mapping" "dynamodb_lambda_trigger" {
  event_source_arn  = aws_dynamodb_table.example_table.stream_arn
  function_name     = aws_lambda_function.example_lambda.arn
  starting_position = "LATEST" # Start processing from the latest stream record
  batch_size        = 100      # Number of records to process at a time
  enabled           = true
}

# 6. Output the DynamoDB Table Name and Lambda Function Name
output "dynamodb_table_name" {
  value = aws_dynamodb_table.example_table.name
}

output "lambda_function_name" {
  value = aws_lambda_function.example_lambda.function_name
}
````

---

## Example4: Trigger Lambda Function from EventBridge
To trigger an AWS Lambda function from Amazon EventBridge, you need to:
1. Create an EventBridge Rule: Define the rule that matches specific events or schedules.
2. Create a Lambda Function: The function that will be triggered by the EventBridge rule.
3. Grant EventBridge Permission to Invoke the Lambda Function: Allow EventBridge to invoke the Lambda function.
4. Configure the EventBridge Rule to Trigger the Lambda Function: Set the Lambda function as the target for the EventBridge rule.
````hcl
# 1. Create an EventBridge Rule
resource "aws_cloudwatch_event_rule" "example_rule" {
  name        = "example-eventbridge-rule"
  description = "Trigger Lambda function on a schedule or specific event."

  # Example: Trigger every 5 minutes (cron expression)
  schedule_expression = "rate(5 minutes)"

  # Alternatively, you can use an event pattern to match specific events:
  # event_pattern = jsonencode({
  #   source      = ["aws.ec2"]
  #   detail-type = ["EC2 Instance State-change Notification"]
  #   detail = {
  #     state = ["stopped", "terminated"]
  #   }
  # })
}

# 2. Create an IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Attach Policies to the IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 4. Create a Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "eventbridge-trigger-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Replace with your preferred runtime

  # Use a placeholder code for the Lambda function
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

# 5. Grant EventBridge Permission to Invoke the Lambda Function
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.example_rule.arn
}

# 6. Configure the EventBridge Rule to Trigger the Lambda Function
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.example_rule.name
  target_id = "lambda-target"
  arn       = aws_lambda_function.example_lambda.arn
}

# 7. Output the EventBridge Rule Name and Lambda Function Name
output "eventbridge_rule_name" {
  value = aws_cloudwatch_event_rule.example_rule.name
}

output "lambda_function_name" {
  value = aws_lambda_function.example_lambda.function_name
}
````

---

## Example5: Trigger Lambda Function from API Gateway
To trigger an AWS Lambda function from Amazon API Gateway, you need to:
1. Create an API Gateway REST API: Define the API endpoint.
2. Create a Lambda Function: The function that will be triggered by the API Gateway.
3. Grant API Gateway Permission to Invoke the Lambda Function: Allow API Gateway to invoke the Lambda function.
4. Integrate the Lambda Function with the API Gateway: Set up the API Gateway to trigger the Lambda function when the endpoint is called.
````hcl
# Provider Configuration
provider "aws" {
  region = "us-east-1"
}

# 1. Create an IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Attach Policies to the IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 3. Create a Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "api-gateway-trigger-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Replace with your preferred runtime

  # Use a placeholder code for the Lambda function
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

# 4. Grant API Gateway Permission to Invoke the Lambda Function
resource "aws_lambda_permission" "allow_api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.example_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # The source_arn specifies which API Gateway can invoke the Lambda function
  source_arn = "${aws_api_gateway_rest_api.example_api.execution_arn}/*/*/*"
}

# 5. Create an API Gateway REST API
resource "aws_api_gateway_rest_api" "example_api" {
  name        = "example-api"
  description = "API Gateway to trigger Lambda function"
}

# 6. Create an API Gateway Resource and Method
resource "aws_api_gateway_resource" "example_resource" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  parent_id   = aws_api_gateway_rest_api.example_api.root_resource_id
  path_part   = "example"
}

resource "aws_api_gateway_method" "example_method" {
  rest_api_id   = aws_api_gateway_rest_api.example_api.id
  resource_id   = aws_api_gateway_resource.example_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# 7. Integrate the Lambda Function with the API Gateway
resource "aws_api_gateway_integration" "example_integration" {
  rest_api_id             = aws_api_gateway_rest_api.example_api.id
  resource_id             = aws_api_gateway_resource.example_resource.id
  http_method             = aws_api_gateway_method.example_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.example_lambda.invoke_arn
}

# 8. Deploy the API Gateway
resource "aws_api_gateway_deployment" "example_deployment" {
  rest_api_id = aws_api_gateway_rest_api.example_api.id
  stage_name  = "prod"

  depends_on = [aws_api_gateway_integration.example_integration]
}

# 9. Output the API Gateway Invoke URL
output "api_gateway_invoke_url" {
  value = "${aws_api_gateway_deployment.example_deployment.invoke_url}/${aws_api_gateway_resource.example_resource.path_part}"
}
````
Testing the Setup
````bash
curl -X POST -d '{"key": "value"}' <api_gateway_invoke_url>
````


---

## Example6: Trigger Lambda Function from Step Function
To trigger an AWS Lambda function from AWS Step Functions, you need to:
1. Create a Lambda Function: The function that will be invoked by the Step Functions state machine.
2. Create a Step Functions State Machine: Define the workflow that includes the Lambda function as a task.
3. Grant Step Functions Permission to Invoke the Lambda Function: Allow Step Functions to invoke the Lambda function.
````hcl
# 1. Create an IAM Role for the Lambda Function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# 2. Attach Policies to the IAM Role
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# 3. Create a Lambda Function
resource "aws_lambda_function" "example_lambda" {
  function_name = "step-function-trigger-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "index.handler"
  runtime       = "nodejs18.x" # Replace with your preferred runtime

  # Use a placeholder code for the Lambda function
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")
}

# 4. Create an IAM Role for Step Functions
resource "aws_iam_role" "step_function_role" {
  name = "step_function_execution_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "states.amazonaws.com"
        }
      }
    ]
  })
}

# 5. Attach Policies to the Step Functions Role
resource "aws_iam_role_policy" "step_function_policy" {
  role = aws_iam_role.step_function_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "lambda:InvokeFunction"
        ]
        Effect   = "Allow"
        Resource = aws_lambda_function.example_lambda.arn
      }
    ]
  })
}

# 6. Create a Step Functions State Machine
resource "aws_sfn_state_machine" "example_state_machine" {
  name     = "example-state-machine"
  role_arn = aws_iam_role.step_function_role.arn

  definition = jsonencode({
    Comment = "A simple AWS Step Functions state machine that triggers a Lambda function"
    StartAt = "InvokeLambda"
    States = {
      InvokeLambda = {
        Type       = "Task"
        Resource   = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = aws_lambda_function.example_lambda.arn
          Payload      = { "input.$" = "$" }
        }
        End = true
      }
    }
  })
}

# 7. Output the Step Functions State Machine ARN
output "step_function_state_machine_arn" {
  value = aws_sfn_state_machine.example_state_machine.id
}
````