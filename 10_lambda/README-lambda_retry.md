# AWS Lambda Retry
Configuring retries for AWS Lambda depends on the **invocation type** (asynchronous or stream-based). Here's how you can configure retries for both cases:

## 1. Asynchronous Invocations:
Retries for asynchronous invocations are managed via the Event Invoke Configuration. You can set the following:
- **Maximum Retry Attempts**: The number of times AWS retries an invocation after the initial failure.
- **Maximum Event Age**: The maximum time (in seconds) AWS retains an event before discarding it.

Terraform Example
````hcl
resource "aws_lambda_function" "my_lambda" {
  ......
}

resource "aws_lambda_event_invoke_config" "my_lambda_invoke_config" {
  function_name                  = aws_lambda_function.my_lambda.function_name
  maximum_retry_attempts         = 3
  maximum_event_age_in_seconds   = 3600 # Retain events for 1 hour before discarding

  /*destination_config {
    on_success {
      destination = aws_sqs_queue.success_queue.arn
    }

    on_failure {
      destination = aws_sqs_queue.failure_queue.arn
    }
  }*/
}
````

AWS CLI Example
````bash
aws lambda put-function-event-invoke-config \
  --function-name my_lambda_function \
  --maximum-retry-attempts 2 \
  --maximum-event-age-in-seconds 3600
````


## 2. EventBridge or SQS
For **EventBridge** or **SQS**, retries are configured in the source service:
- **EventBridge**:
  - Retry policy and dead-letter queue (DLQ) can be set in the event rule.
- **SQS**:
  - Configure the Redrive Policy for DLQ handling.


## 3. Stream-Based Invocations (e.g., Kinesis, DynamoDB Streams)
For stream-based services, retries are managed using the **Event Source Mapping Configuration**. The Lambda function keeps retrying the failed record until:
- The record expires in the stream (24 hours for Kinesis, 7 days for DynamoDB Streams).
- The function succeeds in processing the record.

Terraform Example
````hcl
resource "aws_lambda_event_source_mapping" "kinesis_mapping" {
  event_source_arn            = aws_kinesis_stream.my_stream.arn
  function_name               = aws_lambda_function.my_lambda.arn
  starting_position           = "LATEST"
  batch_size                  = 100
  maximum_retry_attempts      = 3
  bisect_batch_on_function_error = true
  maximum_record_age_in_seconds = 3600
}
````

AWS CLI Example
````bash
aws lambda update-event-source-mapping \
  --uuid "mapping-uuid" \
  --batch-size 100 \
  --maximum-retry-attempts 3 \
  --bisect-batch-on-function-error \
  --maximum-record-age-in-seconds 3600
````


## Tips for Effective Retry Configuration:
1. **Dead-Letter Queue (DLQ)**: Always configure a DLQ (e.g., SQS or SNS) to capture events that fail after retries.
2. **Idempotency**: Ensure your Lambda function logic is idempotent, as retries may cause duplicate events.
3. **Monitoring**: Use Amazon CloudWatch to track retries and failures.