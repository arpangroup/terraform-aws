import boto3
import time

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

                # Optional: Extract the MessageGroupId
                message_group_id = message.get('MessageGroupId')
                print(f"Message Group ID: {message_group_id}")
                # Process the message only if it matches the desired group ID

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


# Polling for messages from the queue
def consume_fifo_messages():
    desired_group_id = 'group1'  # Replace with the desired MessageGroupId

    while True:
        # Receive a message from the FIFO queue
        response = sqs.receive_message(
            QueueUrl=queue_url,
            AttributeNames=['All'],
            MaxNumberOfMessages=10,  # Maximum messages to fetch in one batch (up to 10)
            WaitTimeSeconds=20,  # Long polling, to wait for messages to arrive
            MessageAttributeNames=['All']
        )

        # Check if there are any messages
        if 'Messages' in response:
            for message in response['Messages']:
                # Process the message
                print(f"Received message: {message['Body']}")

                # Extract the MessageGroupId
                message_group_id = message.get('MessageGroupId')
                print(f"Message Group ID: {message_group_id}")

                # Process the message only if it matches the desired group ID
                if message_group_id == desired_group_id:
                    print(f"Processing message: {message['Body']}")

                    # Process the message here (e.g., perform work)

                    # Delete the message after processing
                    sqs.delete_message(
                        QueueUrl=queue_url,
                        ReceiptHandle=message['ReceiptHandle']
                    )
                    print(f"Message with group ID {message_group_id} deleted successfully.")
                    return
        else:
            print("No messages received. Waiting for messages...")

        # Optional: Sleep between polls
        time.sleep(1)


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
