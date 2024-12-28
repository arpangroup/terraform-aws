import boto3
import csv
import os
import json

s3 = boto3.client('s3')
sqs = boto3.client('sqs')

CONSUMER_QUEUE_URL = os.environ['CONSUMER_QUEUE_URL']

# Lambda handler
def lambda_handler(event, context):
    try:
        # Extract S3 bucket name and file key from the event
        bucket_name = event['Records'][0]['s3']['bucket']['name']
        file_key = event['Records'][0]['s3']['object']['key']

        print(f"Reading file {file_key} from bucket {bucket_name}")

        # Download the file from S3
        local_file_path = f"/tmp/{os.path.basename(file_key)}"
        s3.download_file(bucket_name, file_key, local_file_path)

        # Process the CSV file
        with open(local_file_path, 'r') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                message = json.dumps(row)
                # Send each row to the SQS queue
                sqs.send_message(QueueUrl=CONSUMER_QUEUE_URL, MessageBody=message)
                print(f"Sent message: {message}")

        return {
            'statusCode': 200,
            'body': json.dumps('File processed and data pushed to queue')
        }

    except Exception as e:
        print(f"Error processing file: {e}")
        return {
            'statusCode': 500,
            'body': json.dumps(f"Error processing file: {e}")
        }
