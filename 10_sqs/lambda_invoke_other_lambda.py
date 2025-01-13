import boto3

def invoke_lambda():
    # Initialize the Lambda client
    client = boto3.client('lambda')

    # Define the name of the Lambda function you want to invoke
    function_name = 'your-target-lambda-function-name'

    # Define the payload to pass to the Lambda function (if needed)
    payload = {
        "key1": "value1",
        "key2": "value2"
    }

    # Invoke the Lambda function
    response = client.invoke(
        FunctionName=function_name,
        InvocationType='RequestResponse',  # 'Event' for async execution
        Payload=str(payload)
    )

    # Read the response payload
    response_payload = response['Payload'].read().decode('utf-8')

    print("Response:", response_payload)

# Call the function
invoke_lambda()
