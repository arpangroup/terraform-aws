import boto3

# Initialize the SQS client
sqs = boto3.client('sqs', region_name='us-east-1')  # Replace with your region
queue_url = 'https://sqs.us-east-1.amazonaws.com/491085411576/order-processing-queue'

def consume_messages():
    try:
        # Receive messages from the queue
        response = sqs.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=10,  # Adjust the number of messages to retrieve <-- consume_messages_in_batch
            WaitTimeSeconds=10,  # Long polling to reduce empty responses
            VisibilityTimeout=30  # Time the message is hidden from other consumers
        )

        if 'Messages' in response:
            for message in response['Messages']:
                print("Received message:")
                print(f"MessageId: {message['MessageId']}")
                print(f"Body: {message['Body']}")

                # Process the message here

                # Delete the message after processing
                sqs.delete_message(
                    QueueUrl=queue_url,
                    ReceiptHandle=message['ReceiptHandle']
                )
                print("Message deleted.")
        else:
            print("No messages available.")

    except Exception as e:
        print(f"Error receiving messages: {str(e)}")


def delete_messages_in_batch():
    try:
        # Receive messages from the queue
        response = sqs.receive_message(
            QueueUrl=queue_url,
            MaxNumberOfMessages=10,  # Adjust the number of messages to retrieve
            WaitTimeSeconds=10,  # Long polling to reduce empty responses
            VisibilityTimeout=30  # Time the message is hidden from other consumers
        )

        if 'Messages' in response:
            # Prepare entries for batch deletion
            entries = [
                {
                    'Id': message['MessageId'],  # Unique ID for this deletion request
                    'ReceiptHandle': message['ReceiptHandle']
                }
                for message in response['Messages']
            ]

            # Delete messages in a batch
            delete_response = sqs.delete_message_batch(
                QueueUrl=queue_url,
                Entries=entries
            )

            print("Batch delete response:", delete_response)
        else:
            print("No messages available for deletion.")

    except Exception as e:
        print(f"Error during batch deletion: {str(e)}")


if __name__ == "__main__":
    consume_messages()
