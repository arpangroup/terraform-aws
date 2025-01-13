import boto3

sqs = boto3.client('sqs', region_name='us-east-1')
queue_url = 'https://sqs.us-east-1.amazonaws.com/491085411576/order-processing-queue'

def publish_messages():
    messages = [
        {"Id": "1", "MessageBody": "{\"orderId\": \"12345\", \"status\": \"created\"}"},
        {"Id": "2", "MessageBody": "{\"orderId\": \"67890\", \"status\": \"pending\"}"},
        {"Id": "3", "MessageBody": "{\"orderId\": \"54321\", \"status\": \"shipped\"}"},
    ]

    response = sqs.send_message_batch(
        QueueUrl=queue_url,
        Entries=messages
    )

    print("Messages pushed:", response)

def publish_messages_with_groupId():
    # Define the message body and MessageGroupId
    message_body = '{"orderId": "12345", "status": "created"}'
    message_group_id = 'group1'  # MessageGroupId to group the message

    # Send the message to the FIFO queue
    response = sqs.send_message(
        QueueUrl=queue_url,
        MessageBody=message_body,
        MessageGroupId=message_group_id,  # MessageGroupId for grouping
        # Optional: deduplication ID for avoiding duplicate messages
        # MessageDeduplicationId='unique-deduplication-id'
    )

    print(f"Message sent! Message ID: {response['MessageId']}")


if __name__ == "__main__":
    publish_messages()