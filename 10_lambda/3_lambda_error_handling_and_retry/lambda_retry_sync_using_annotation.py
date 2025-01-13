import logging
import json
import random
import time

# Configure logging
log = logging.getLogger()
log.setLevel(logging.INFO)  # Set the logging level to INFO


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


@retry(3, 1, 2, Exception)
def task():
    log.info("performing a task.....")
    if random.random() < 0.7:  # 70% chance of failure
        raise Exception("Simulated Task Failure....")
    log.info("Task succeeded!!")


@retry(max_retries=3, initial_delay=1, backoff_factor=2, exceptions=(ConnectionError,))
def call_external_service():
    # Simulate a function that might fail
    import random
    if random.random() < 0.7:  # 70% chance of failure
        raise ConnectionError("Failed to connect to the external service")
    return "Success"


def lambda_handler(event, context):
    try:
        # retry(task, max_retries, initial_delay)
        result = call_external_service()
        return {"statusCode": 200, "body": result}
    except Exception as e:
        log.error(f"Task failed after {max_retries} attempts: {e}")
        return {"statusCode": 500, "body": f"Error: {str(e)}"}


