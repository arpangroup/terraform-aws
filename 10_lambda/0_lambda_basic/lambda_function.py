import json
import logging

def lambda_handler(event, context):
    """
    AWS Lambda function handler.
    :param event: The input event to the function (JSON object).
    :param context: The runtime information for the invocation.
    :return: A response object.
    """
    print("Event: ", event)  # Log the input event for debugging.
    logging.info("Executing Event: ", event)

    response = {
        "statusCode": 200,
        "body": json.dumps({
            "response": "Hello, Response from LambdaFunction!!",
            "input_event": event
        }),
    }
    return response
