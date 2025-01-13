# Asynchronous Error:
- Retry 2 times after failure
- If above 2 Retry fails, then lambda send the failed events to either of following:
    - DLQ or
    - **Destinations**(`onSuccess` or `onFailure`)
- Configuration:
    - MaximumRecordAge
    - MaximumRetryAttempts
    - BisectBatchOnFunctionError

## Amazon SQS Event Source:
**Retry behavior**: until message expires
- Default: retry all message in batch
- Function can delete completed messages


## Step Function Event Source:
- Retry behavior  : Configurable
- Specify using **Retry**, by error type


---

## Step1: Create an Asynchronous Retry behavior
1. **Create the main SQS queue**: This is the queue where your messages will initially be sent.
2. **Create the Dead Letter Queue (DLQ)**: This queue will store messages that fail to be processed after a certain number of retries.
3. **Configure the redrive policy**: This policy will define how many times a message can be retried before it is sent to the DLQ.
4. **Create an AWS Lambda function**: This function will process messages from the main SQS queue.
5. **Set up the event source mapping**: This will trigger the Lambda function whenever a message is sent to the main SQS queue.

````hcl
provider "aws" {
  region = "us-east-1"
}

# Create the main SQS queue
resource "aws_sqs_queue" "main_queue" {
  name                      = "main-queue"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600 # 4 days
  visibility_timeout_seconds = 30    # Adjust based on your Lambda function's execution time

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3 # Number of retries before sending to DLQ
  })

  tags = {
    Environment = "production"
  }
}

# Create the Dead Letter Queue (DLQ)
resource "aws_sqs_queue" "dlq" {
  name                      = "dlq"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 1209600 # 14 days

  tags = {
    Environment = "production"
  }
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"

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

# Attach the necessary policies to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sqs_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSQSFullAccess"
}

resource "aws_iam_role_policy_attachment" "lambda_basic_execution_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# Create the Lambda function
resource "aws_lambda_function" "sqs_processor" {
  function_name = "sqs-processor"
  handler       = "index.handler"
  runtime       = "nodejs14.x" # Change to your preferred runtime
  role          = aws_iam_role.lambda_role.arn

  # Replace with your Lambda function code
  filename         = "lambda_function_payload.zip"
  source_code_hash = filebase64sha256("lambda_function_payload.zip")

  environment {
    variables = {
      QUEUE_URL = aws_sqs_queue.main_queue.id
    }
  }
}

# Create the event source mapping to trigger the Lambda function
resource "aws_lambda_event_source_mapping" "event_source_mapping" {
  event_source_arn = aws_sqs_queue.main_queue.arn
  function_name    = aws_lambda_function.sqs_processor.arn
  batch_size       = 10
}
````
Explanation:
1. **Main SQS Queue**: The `aws_sqs_queue.main_queue` resource creates the main queue. The `redrive_policy` specifies that after 3 retries (`maxReceiveCount`), the message should be sent to the DLQ.
2. **Dead Letter Queue**: `The aws_sqs_queue.dlq` resource creates the DLQ where failed messages will be stored.
3. **IAM Role**: The `aws_iam_role.lambda_role` resource creates an IAM role that allows the Lambda function to access SQS and execute.
4. **Lambda Function**: The `aws_lambda_function.sqs_processor` resource creates a Lambda function that processes messages from the main queue. Replace the `filename` and source_code_hash with your actual Lambda function code.
5. **Event Source Mapping**: The aws_lambda_event_source_mapping.event_source_mapping resource sets up the trigger so that the Lambda function is invoked whenever a message is sent to the main queue.

Notes:
- Adjust the `visibility_timeout_seconds` based on how long your Lambda function takes to process a message.


---
## Step2: The Lambda Function:
````python
import json
import boto3
import os

# Initialize SQS client
sqs = boto3.client('sqs')

# Get the main queue URL from the environment variable
QUEUE_URL = os.environ['QUEUE_URL']

def process_message(message_body):
    """
    Simulates message processing logic.
    Raises an exception to mimic a failure and trigger a retry.
    """
    print(f"Processing message: {message_body}")

    # Simulate a failure condition (e.g., based on message content)
    if "fail" in message_body.lower():
        raise Exception("Simulated processing failure!")

    # Simulate successful processing
    print("Message processed successfully!")
    return True

def lambda_handler(event, context):
    """
    Lambda function handler to process messages from the SQS queue.
    """
    for record in event['Records']:
        try:
            # Extract the message body
            message_body = record['body']
            print(f"Received message: {message_body}")

            # Process the message
            process_message(message_body)

            # Delete the message from the queue if processing is successful
            receipt_handle = record['receiptHandle']
            sqs.delete_message(
                QueueUrl=QUEUE_URL,
                ReceiptHandle=receipt_handle
            )
            print("Message deleted from the queue.")

        except Exception as e:
            print(f"Error processing message: {str(e)}")
            # Raise the exception to trigger SQS retry behavior
            raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Message processing complete.')
    }
````




---

## Step3: Testing the Setup
Send a message to the main SQS queue using the AWS CLI or AWS Management Console.
Example message:
````
{"message": "This is a test message."}
````
To test retries, send a message like: 
````
"message": "This message will fail."}
````


---

## Step4 (Optional): implement a retry behavior where the Lambda function retries processing messages until they expire
To implement a retry behavior where the Lambda function retries processing messages until they expire (i.e., until the **messageRetentionPeriod** of the SQS queue is reached), and the function deletes only successfully processed messages, you can modify the Lambda function and Terraform configuration as follows:

#### Updated Python Lambda Function:
The Lambda function will:
1. Process all messages in the batch.
2. Retry failed messages until they expire (SQS will handle this automatically).
3. Delete only successfully processed messages from the queue.

````python
import json
import boto3
import os

# Initialize SQS client
sqs = boto3.client('sqs')

# Get the main queue URL from the environment variable
QUEUE_URL = os.environ['QUEUE_URL']

def process_message(message_body):
    """
    Simulates message processing logic.
    Raises an exception to mimic a failure and trigger a retry.
    """
    print(f"Processing message: {message_body}")

    # Simulate a failure condition (e.g., based on message content)
    if "fail" in message_body.lower():
        raise Exception("Simulated processing failure!")

    # Simulate successful processing
    print("Message processed successfully!")
    return True

def lambda_handler(event, context):
    """
    Lambda function handler to process messages from the SQS queue.
    """
    success_messages = []  # Stores receipt handles of successfully processed messages

    for record in event['Records']:
        try:
            # Extract the message body
            message_body = record['body']
            print(f"Received message: {message_body}")

            # Process the message
            process_message(message_body)

            # If processing is successful, add the receipt handle to the success list
            success_messages.append({
                'Id': record['messageId'],
                'ReceiptHandle': record['receiptHandle']
            })

        except Exception as e:
            print(f"Error processing message: {str(e)}")
            # Do not delete the message; let it remain in the queue for retries

    # Delete successfully processed messages in bulk
    if success_messages:
        print(f"Deleting {len(success_messages)} successfully processed messages.")
        entries = [{'Id': msg['Id'], 'ReceiptHandle': msg['ReceiptHandle']} for msg in success_messages]
        sqs.delete_message_batch(QueueUrl=QUEUE_URL, Entries=entries)

    return {
        'statusCode': 200,
        'body': json.dumps('Message processing complete.')
    }
````




