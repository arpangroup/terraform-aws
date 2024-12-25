# Secure API Gateway Requests with AWS Lambda Authorizer
To enforce that an AWS Lambda function can only be executed if a valid authentication token is provided, you can use AWS Lambda function URLs with **AWS IAM Authentication** or an **API Gateway** with **Custom Authorizers** (such as using a Lambda Authorizer or AWS Cognito) to verify the authentication token before executing the function.

## 1. Using AWS API Gateway with Lambda Authorizer (Custom Authorizer)
### Step1.1: Create a Lambda Function to Serve as the Authorizer:
The Lambda authorizer will check if the incoming token is valid. For example, you could validate a JWT token by using a third-party library like `jsonwebtoken`.

````python
import json

def lambda_handler(event, context):
    """
    AWS Lambda Authorizer function to validate tokens.
    
    :param event: The incoming event payload. Expects the "Authorization" header.
    :param context: AWS Lambda context object.
    :return: IAM policy allowing or denying access.
    """
    # Extract the Authorization token from the event headers
    token = event.get('headers', {}).get('Authorization')

    # Validate the token
    if not token or not is_valid_token(token):
        return generate_policy("user", "Deny", event.get("methodArn"))

    # Return an Allow policy if the token is valid
    return generate_policy("user", "Allow", event.get("methodArn"))


def is_valid_token(token):
    """
    Validates the provided token. Replace this logic with actual token validation.
    
    :param token: The token to validate.
    :return: True if the token is valid, False otherwise.
    """
    # Example: Replace this with real validation logic, such as verifying a JWT
    valid_tokens = ["valid-token-1", "valid-token-2"]  # Example valid tokens
    return token in valid_tokens


def generate_policy(principal_id, effect, resource):
    """
    Generates an IAM policy.

    :param principal_id: The principal user identifier.
    :param effect: Allow or Deny.
    :param resource: The resource ARN.
    :return: A properly formatted IAM policy.
    """
    if effect not in ["Allow", "Deny"]:
        raise ValueError("Effect must be 'Allow' or 'Deny'")

    policy = {
        "principalId": principal_id,
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": effect,
                    "Resource": resource
                }
            ]
        }
    }
    return policy
````
### Step1.2: Create an API Gateway REST API:
1. Go to the API Gateway Console and create a new REST API.
2. Create a `Lambda Authorizer` that uses the `TokenValidator` Lambda function to check for a valid token.
   - Select **Lambda** as the authorizer type.
   - Set the **Token Source** to `Authorization` (the default HTTP header where tokens are usually passed).
   - Attach this Lambda authorizer to your API Gateway method.
3. **Define Your Lambda Function**: Create the Lambda function that will process the request if the token is valid. This function will be the one you are trying to secure with authentication.
4. **Configure API Gateway Method**: In your API Gateway method (e.g.,` POST /my-lambda`), ensure that it invokes the Lambda function only if the token is validated by the Lambda authorizer. If the token is invalid, API Gateway will reject the request with a 401 Unauthorized status.
5. **Deploy the API**: Deploy your API and test it by sending requests with valid and invalid tokens <br/><br/>

    Example Request with Token:
    ````bash
    curl -X POST https://your-api-id.execute-api.us-east-1.amazonaws.com/prod/my-lambda \
    -H "Authorization: valid-token" \
    -H "Content-Type: application/json" \
    -d '{"key1": "value1"}'
    ````

## 2. Using AWS Lambda Function URL with IAM Authentication
AWS Lambda function URLs now support IAM Authentication, which means that only requests with a valid IAM token can invoke the Lambda function.
1. Enable IAM Authentication for Lambda URL
2. Invoke Lambda Function with IAM Authentication

**Steps to Configure:**
````hcl
resource "aws_lambda_function_url" "my_lambda_url" {
  function_name        = aws_lambda_function.my_lambda.function_name
  authorization_type   = "AWS_IAM"
}
````

Calling the Lambda Function Using AWS CLI:
````bash
aws lambda invoke \
  --function-name arn:aws:lambda:us-east-1:123456789012:function:my-lambda-function \
  --cli-binary-format raw-in-base64-out \
  --payload '{"key1": "value1"}' \
  output.json
````