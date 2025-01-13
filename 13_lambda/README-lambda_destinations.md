# AWS Lambda Destination Configurations

### Supported Destinations:
- **Amazon SQS**: Send results to a queue.
- **Amazon SNS**: Publish results to a topic.
- **EventBridge**: Trigger custom events based on the results.
- **Another Lambda function**: Process results in another Lambda function.

### Types of Invocations:
- **On Success**: Routes successful execution results to the specified destination.
- **On Failure**: Routes failure events, including retry attempts, to the specified destination.


### Example Configuration
````bash
aws lambda put-function-event-invoke-config \
  --function-name MyFunction \
  --maximum-retry-attempts 2 \
  --maximum-event-age-in-seconds 3600 \
  --destination-config '{"OnSuccess":{"Destination":"arn:aws:sqs:region:account-id:queue-name"}, "OnFailure":{"Destination":"arn:aws:sns:region:account-id:topic-name"}}'
````

or using Terraform
````hcl
resource "aws_lambda_function" "my_lambda" {
  ......
}
resource "aws_sqs_queue" "success_queue" {
  name = "lambda-success-queue"
}
resource "aws_sqs_queue" "failure_queue" {
  name = "lambda-failure-queue"
}
resource "aws_lambda_event_invoke_config" "my_lambda_invoke_config" {
  function_name                  = aws_lambda_function.my_lambda.function_name
  maximum_retry_attempts         = 3
  maximum_event_age_in_seconds   = 3600

  destination_config {
    on_success {
      destination = aws_sqs_queue.success_queue.arn
    }

    on_failure {
      destination = aws_sqs_queue.failure_queue.arn
    }
  }
}

````