## Error Handling on AWS Lambda
- Asynchronous
- Synchronous

---
## 2. Synchronous Error:
In case of Synchronous invocation we need to return the proper error status, so that client can understand about the error
- **Retry behavior**: **None**
  - Client must RETRY on failure


In `error_config.py`:
````python
# Centralized error codes and messages
ERRORS = {
    # Client errors (4xx)
    400: {
        "INVALID_INPUT": "Invalid input provided",
        "MISSING_FIELD": "Required field is missing",
    },
    404: {
        "RESOURCE_NOT_FOUND": "The requested resource was not found",
    },
    # Server errors (5xx)
    500: {
        "INTERNAL_ERROR": "An internal server error occurred",
        "DATABASE_ERROR": "Failed to connect to the database",
    },
}

ERROR_CODES = {
    # Client errors (4xx)    
    "INVALID_INPUT" : (400, "ERR001", "Invalid input provided"),
    "MISSING_FIELD" : (400, "ERR002", "Required field is missing"),

    "RESOURCE_NOT_FOUND": (404, "The requested resource was not found"),

    # Server errors (5xx)
    "INTERNAL_ERROR": (500, "An internal server error occurred"),
    "DATABASE_ERROR": (500, "Failed to connect to the database")
}


def get_error_message(status_code, error_key):
    """Retrieve error message based on status code and error key."""
    return ERRORS.get(status_code, {}).get(error_key, "Unknown error occurred")

def error_400(error_key):
    """Retrieve error message based on status code and error key."""
    error = ERROR_CODES.get(error_key, {})
    return {
        'statusCode': error[0],
        'body': json.dumps({
            'error_code': error[1],
            'message': error[2],
            'details': None
        })
    }

def error_500(error_key, e=None):
    error = ERROR_CODES.get(error_key, {})
    return {
        'statusCode': 500,
        'body': json.dumps({
            'error_code': 'INTERNAL_ERROR',
            'message': error[1]
            'details': str(e)  # Optional: Include exception details for debugging
        })
    }
````

In `error_utils.py`:
````python
def create_error_response(status_code, error_code, error_key, details=None):
    """
    Creates a standardized error response object.

    :param status_code: HTTP status code (e.g., 400, 500)
    :param error_code: A unique error code (e.g., "INVALID_INPUT")
    :param message: A human-readable error message
    :param details: Optional additional details for debugging
    :return: A dictionary representing the error response
    """
    error_response = {
        'statusCode': status_code,
        'body': json.dumps({
            'error_code': error_code,
            'message': error_config.get_error_message(400, 'MISSING_FIELD'),
            'details': details
        })
    }
    return error_response
````

In `lambda_function.py`:
````python
import json
import error_config
import error_utils

def lambda_handler(event, context):
    try:
        # Example: Validate input
        if 'username' not in event:
            return error_400("MISSING_FIELD")

        # Your business logic here
        return {
            'statusCode': 200,
            'body': json.dumps({'message': 'Success'})
        }

    except Exception as e:
        # Handle unexpected errors
        return error_500("INTERNAL_ERROR", e)
````
--- 

## Using Custom Exception on Python

Step 1: Define Custom Exceptions in `exceptions.py`:
````python
class CustomError(Exception):
    """Base class for custom exceptions"""
    pass

class ValidationError(CustomError):
    """Raised when input validation fails"""
    pass

class DatabaseError(CustomError):
    """Raised when there is a database-related error"""
    pass

class NetworkError(CustomError):
  """Raised when there is a network-related error"""
  pass
````
main.py:
````python
from exceptions import ValidationError, DatabaseError, NetworkError

def process_data(data):
  try:
    if not data:
      raise ValidationError("Input data cannot be empty")
    # Simulate other operations
  except ValidationError as e:
    print(e)
  except DatabaseError as e:
    print(e)
  except NetworkError as e:
    print(e)

# Test the function
process_data(None)
````

Step 2: Create the `@error_handler` Decorator
````python
def error_handler(func):
    def wrapper(*args, **kwargs):
        try:
            return func(*args, **kwargs)
        except ValidationError as e:
            return {
                'statusCode': 400,
                'body': f'Validation Error: {str(e)}'
            }
        except DatabaseError as e:
            return {
                'statusCode': 500,
                'body': f'Database Error: {str(e)}'
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': f'Internal Server Error: {str(e)}'
            }
    return wrapper
````

Step 3: Use the Decorator in Your Lambda Function
````python
@error_handler
def lambda_handler(event, context):
    # Example logic that might raise custom exceptions
    if 'name' not in event:
        raise ValidationError("Name is required")
    
    if event.get('name') == 'admin':
        raise DatabaseError("Admin access denied")
    
    return {
        'statusCode': 200,
        'body': f'Hello, {event["name"]}!'
    }
````

---

## @lambda_handler_decorator (aws_lambda_powertools middleware)
The `@lambda_handler_decorator` is a concept that can be used to wrap your AWS Lambda handler function with additional functionality, such as error handling, logging, or input validation. This approach is similar to the `@error_handler` decorator but is more generic and can be used for a variety of purposes.

Step 2: Create the `@lambda_handler_decorator`
````python
def lambda_handler_decorator(func):
    def wrapper(event, context):
        try:
            # Call the original Lambda handler function
            return func(event, context)
        except ValidationError as e:
            return {
                'statusCode': 400,
                'body': f'Validation Error: {str(e)}'
            }
        except DatabaseError as e:
            return {
                'statusCode': 500,
                'body': f'Database Error: {str(e)}'
            }
        except Exception as e:
            return {
                'statusCode': 500,
                'body': f'Internal Server Error: {str(e)}'
            }
    return wrapper
````

Step 3: Use the @lambda_handler_decorator in Your Lambda Function
````python
@lambda_handler_decorator
def lambda_handler(event, context):
    # Example logic that might raise custom exceptions
    if 'name' not in event:
        raise ValidationError("Name is required")
    
    if event.get('name') == 'admin':
        raise DatabaseError("Admin access denied")
    
    return {
        'statusCode': 200,
        'body': f'Hello, {event["name"]}!'
    }
````

---
## EXAMPLE1:
````python
from aws_lambda_powertools.utilities.batch import sqs_batch_processor
@error_handler
def handler(event, context):
    book = findBook(event.get('book_id'))
    if book is None:
        raise BookNotFoundException(book_id) # custom exception
    return { "statusCode": 200, "body": json.dumps(book) }

@lambda_handler_decorator(trace_execution=True) # aws_lambda_powertools middleware
def error_handler(handler, event, context):
  logger = Logger(child=True)
  
  try:
    return handler(event, context)
  except Exception as err:
    logger.exception(err) # log error message and metrics
    if err.code < 500:
      return sanitize_error(err) # return sanitize error to client
    raise CustomException from err # re-raise error to indicate failure      

````

## EXAMPLE2:
````python
@error_handler
def handler(event, context):
  return { ... }

@lambda_handler_decorator(trace_execution=True) # aws_lambda_powertools middleware
def error_handler(handler, event, context):
  logger = Logger(child=True)
  handler = logger.inject_lambda_context(handler) # inject Lambda context info
  
  try:
    return handler(event, context)
  except botocore.exceptions.ClientError as err:
    logger.exception(err.message) # log error message and metrics for AWS clients
    raise CustomException from err
  except Exception as err:
    logger.exception(err) # log error message and metrics
    raise CustomException from err

````


---
## 1. ASynchronous Error:
- Retry 2 times after failure
- Destinations
  - DLQ or
  - **Destinations**(`onSuccess` or `onFailure`)
- Configuration:
  - MaximumRecordAge
  - MaximumRetryAttempts
  - BisectBatchOnFunctionError

## Amazon SQS Event Source:
**Retry behavior**: until message expires
- Default: retry all message in batch
- Function can delete completed messages


## Step Function Event Source:
- Retry behavior  : Configurable
- Specify using **Retry**, by error type
- 

--- 

## Create Retry Logic
#### Step 1: Define a Retry Decorator
````python
import time
import logging

logging.basicConfig(level=logging.INFO)

def retry(max_retries=3, delay=1, exceptions=(Exception,)):
    """
    A decorator to retry a function in case of specified exceptions.

    :param max_retries: Maximum number of retries.
    :param delay: Delay between retries in seconds.
    :param exceptions: Tuple of exceptions to catch and retry.
    """
    def decorator(func):
        def wrapper(*args, **kwargs):
            retries = 0
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    retries += 1
                    if retries >= max_retries:
                        logging.error(f"Max retries ({max_retries}) reached. Last error: {str(e)}")
                        raise
                    logging.warning(f"Retry {retries}/{max_retries} after error: {str(e)}")
                    time.sleep(delay)
        return wrapper
    return decorator
````

#### Step 2: Use the Retry Decorator in Your Lambda Function
````python
@retry(max_retries=3, delay=2, exceptions=(ConnectionError,))
def call_external_service():
    # Simulate a function that might fail
    import random
    if random.random() < 0.7:  # 70% chance of failure
        raise ConnectionError("Failed to connect to the external service")
    return "Success"

def lambda_handler(event, context):
    try:
        result = call_external_service()
        return {
            'statusCode': 200,
            'body': result
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': f"Error: {str(e)}"
        }
````

#### Step 3: Test the Lambda Function <br/>
When you invoke the Lambda function, it will retry the call_external_service function up to 3 times with a 2-second delay between retries if a ConnectionError occurs.

- Example Output (Success):
  ````
  INFO:root:Retry 1/3 after error: Failed to connect to the external service
  INFO:root:Retry 2/3 after error: Failed to connect to the external service
  {
    'statusCode': 200,
    'body': 'Success'
  }
  ````
- Example Output (Failure):
  ````
  INFO:root:Retry 1/3 after error: Failed to connect to the external service
  INFO:root:Retry 2/3 after error: Failed to connect to the external service
  INFO:root:Retry 3/3 after error: Failed to connect to the external service
  ERROR:root:Max retries (3) reached. Last error: Failed to connect to the external service
  {
    'statusCode': 500,
    'body': 'Error: Failed to connect to the external service'
  }
  ````

#### Step 4: Customize the Retry Logic
You can customize the retry logic by:
- Adjusting the `max_retries` and `delay` parameters.
- Specifying different exceptions to retry on (e.g., ConnectionError, TimeoutError, etc.).
- Adding exponential backoff for the delay between retries.
````python
def retry(max_retries=3, initial_delay=1, backoff_factor=2, exceptions=(Exception,)):
    """
    A decorator to retry a function with exponential backoff.

    :param max_retries: Maximum number of retries.
    :param initial_delay: Initial delay between retries in seconds.
    :param backoff_factor: Factor by which the delay increases after each retry.
    :param exceptions: Tuple of exceptions to catch and retry.
    """
    def decorator(func):
        def wrapper(*args, **kwargs):
            retries = 0
            delay = initial_delay
            while retries < max_retries:
                try:
                    return func(*args, **kwargs)
                except exceptions as e:
                    retries += 1
                    if retries >= max_retries:
                        logging.error(f"Max retries ({max_retries}) reached. Last error: {str(e)}")
                        raise
                    logging.warning(f"Retry {retries}/{max_retries} after error: {str(e)}. Waiting {delay} seconds...")
                    time.sleep(delay)
                    delay *= backoff_factor
        return wrapper
    return decorator
````

Use it like this:
````python
@retry(max_retries=3, initial_delay=1, backoff_factor=2, exceptions=(ConnectionError,))
def call_external_service():
    # Simulate a function that might fail
    import random
    if random.random() < 0.7:  # 70% chance of failure
        raise ConnectionError("Failed to connect to the external service")
    return "Success"
````