import logging
import json

# Configure logging
log = logging.getLogger()
log.setLevel(logging.INFO)  # Set the logging level to INFO

def lambda_handler(event, context):
    log.info("Received Event: " + json.dumps(event))
    print("Received event:", json.dumps(event))

    # Extract bucket name and object key from the event
    for record in event.get('Records', []):
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        log.info(f"BucketName: {bucket_name}")
        log.info(f"ObjectKey : {object_key}")
        log.info(f"New object created: {object_key} in bucket: {bucket_name}")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda executed successfully!')
    }
