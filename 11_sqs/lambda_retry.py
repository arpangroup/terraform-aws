import time
import random

def retry_function(func, max_retries, initial_delay):
    """Retry decorator with exponential backoff."""
    delay = initial_delay
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            print(f"Attempt {attempt + 1} failed: {e}")
            if attempt < max_retries - 1:
                time.sleep(delay)
                delay *= 2  # Exponential backoff
            else:
                raise

def task():
    """A sample task that might fail."""
    print("Performing a task...")
    if random.random() < 0.7:  # Simulate failure 70% of the time
        raise Exception("Simulated task failure")
    print("Task succeeded!")

def lambda_handler(event, context):
    """AWS Lambda entry point."""
    print("Lambda function started.")
    max_retries = 3
    initial_delay = 2  # Seconds
    try:
        retry_function(task, max_retries, initial_delay)
        return {"statusCode": 200, "body": "Task completed successfully."}
    except Exception as e:
        print(f"Task failed after {max_retries} attempts: {e}")
        return {"statusCode": 500, "body": "Task failed."}
