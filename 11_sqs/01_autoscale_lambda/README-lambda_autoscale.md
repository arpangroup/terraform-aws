# Autoscale Lambda base on SQS
To autoscale an AWS Lambda function based on an SQS queue using Terraform and Python code, you need to set up the following:

1. **AWS Lambda Function**: Create the Lambda function.
2. **SQS Queue**: Create the SQS queue to trigger the Lambda.
3. **Lambda Event Source Mapping**: Set the Lambda to be triggered by the SQS queue.
4. **AWS Application Auto Scaling**: Define a scaling policy for the Lambda based on SQS metrics like the number of messages in the queue.

````hcl
# Create an SQS Queue
resource "aws_sqs_queue" "example" {
  name = "example-queue"
}

# Create the Lambda Function
resource "aws_lambda_function" "example" {
  filename      = "lambda.zip" 
  function_name = "example-lambda"
  role          = aws_iam_role.lambda_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.8"

  environment {
    variables = {
      "SQS_QUEUE_URL" = aws_sqs_queue.example.url
    }
  }
}

# Grant Lambda permission to read from SQS
resource "aws_lambda_permission" "allow_sqs" {
  action        = "lambda:InvokeFunction"
  principal     = "sqs.amazonaws.com"
  function_name = aws_lambda_function.example.function_name
  source_arn    = aws_sqs_queue.example.arn
}

# Lambda Event Source Mapping for SQS
resource "aws_lambda_event_source_mapping" "example" {
  event_source_arn = aws_sqs_queue.example.arn
  function_name    = aws_lambda_function.example.arn
  batch_size       = 5
  enabled          = true
}

# Application Auto Scaling for Lambda
resource "aws_appautoscaling_target" "lambda_target" {
  max_capacity     = 10
  min_capacity     = 1
  resource_id      = "function:${aws_lambda_function.example.function_name}"
  scalable_dimension = "lambda:function:ConcurrentExecutions"
  service_namespace = "aws/lambda"
}

# Scaling policy for Lambda
resource "aws_appautoscaling_policy" "lambda_scaling_policy" {
  name               = "lambda-scaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.lambda_target.resource_id
  scalable_dimension = aws_appautoscaling_target.lambda_target.scalable_dimension
  service_namespace  = "aws/lambda"

  target_tracking_scaling_policy_configuration {
    target_value = 50.0

    predefined_metric_specification {
      predefined_metric_type = "SQSApproximateNumberOfMessagesVisible"
      resource_label         = aws_sqs_queue.example.name
    }

    scale_in_cooldown  = 60
    scale_out_cooldown = 60
  }
}
````
The **auto-scaling policy** in the Terraform configuration is set based on the **SQS queue’s approximate number of messages visible**. The Lambda function scales out (increases the number of concurrent executions) when the number of messages in the queue increases, and scales in when the queue is empty or has fewer messages.