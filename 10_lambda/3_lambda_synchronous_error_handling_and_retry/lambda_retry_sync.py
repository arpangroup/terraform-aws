import logging
import json
import random
import time

# Configure logging
log = logging.getLogger()
log.setLevel(logging.INFO)  # Set the logging level to INFO


def retry(func, max_retries=3, initial_delay=1):
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
    print("performing a task.....")
    if random.random() < 0.7:
        raise Exception("Simulated Task Failure....")
    log.info("Task succeeded!!")


def lambda_handler(event, context):
    log.info("Lambda function started.....: ")
    max_retries = 3
    initial_delay = 2  # seconds\

    try:
        retry(task, max_retries, initial_delay)
        print("SUCCESS")
        return {"statusCode": 200, "body": "Task completed successfully"}
    except Exception as e:
        log.error(f"Task failed after {max_retries} attempts: {e}")
        print("INTERNAL_SERVER_ERROR")
        return {"statusCode": 500, "body": "Task failed"}
