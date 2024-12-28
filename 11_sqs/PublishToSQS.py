import boto3

sqs = boto3.client('sqs')
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





if __name__ == "__main__":
    publish_messages()