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