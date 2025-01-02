import json

def lambda_handler(event, context):
    # Log the received event
    print("Received event:", json.dumps(event))

    # Extract bucket name and object key from the event
    for record in event.get('Records', []):
        bucket_name = record['s3']['bucket']['name']
        object_key = record['s3']['object']['key']

        print(f"New object created: {object_key} in bucket: {bucket_name}")

    return {
        'statusCode': 200,
        'body': json.dumps('Lambda executed successfully!')
    }
