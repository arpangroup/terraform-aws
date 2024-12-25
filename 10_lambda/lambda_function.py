import json

def lambda_handler(event, context):
    """
    AWS Lambda function handler.
    :param event: The input event to the function (JSON object).
    :param context: The runtime information for the invocation.
    :return: A response object.
    """
    print("Event: ", event)  # Log the input event for debugging.

    response = {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Hello, World!",
            "input": event
        }),
    }
    return response
