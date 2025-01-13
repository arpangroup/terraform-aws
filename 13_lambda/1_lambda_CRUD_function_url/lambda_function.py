import logging
import json

# Configure logging
log = logging.getLogger()
log.setLevel(logging.INFO)  # Set the logging level to INFO

# In-memory storage
items = {}


# Main Lambda handler
def lambda_handler(event, context):
    log.info("Received Event: " + json.dumps(event))
    http_method = event['requestContext']['http']['method']
    body = json.loads(event['body']) if 'body' in event and event['body'] else {}
    item_id = event['queryStringParameters']['id'] if 'queryStringParameters' in event and event['queryStringParameters'] else None

    if http_method == 'POST':
        return create_item(body)
    elif http_method == 'GET':
        return read_item(item_id)
    elif http_method == 'PUT':
        return update_item(item_id, body)
    elif http_method == 'DELETE':
        return delete_item(item_id)
    else:
        return generate_response(400, {'message': 'Invalid method'})


# =========================================================================== #
# Helper function to generate a response
def generate_response(status_code, body):
    return {
        'statusCode': status_code,
        'body': json.dumps(body)
    }


# Create (POST)
def create_item(body):
    new_id = str(len(items) + 1)
    items[new_id] = body
    return generate_response(201, {'id': new_id, **body})


# Read (GET)
def read_item(item_id):
    if item_id:
        item = items.get(item_id)
        if item:
            return generate_response(200, item)
        else:
            return generate_response(404, {'message': 'Item not found'})
    else:
        return generate_response(200, items)


# Update (PUT)
def update_item(item_id, body):
    if item_id and item_id in items:
        items[item_id].update(body)
        return generate_response(200, items[item_id])
    else:
        return generate_response(404, {'message': 'Item not found'})


# Delete (DELETE)
def delete_item(item_id):
    if item_id and item_id in items:
        del items[item_id]
        return generate_response(200, {'message': 'Item deleted'})
    else:
        return generate_response(404, {'message': 'Item not found'})


# Main Lambda handler
def lambda_handler(event, context):
    http_method = event['requestContext']['http']['method']
    body = json.loads(event['body']) if 'body' in event and event['body'] else {}
    item_id = event['queryStringParameters']['id'] if 'queryStringParameters' in event and event['queryStringParameters'] else None

    if http_method == 'POST':
        return create_item(body)
    elif http_method == 'GET':
        return read_item(item_id)
    elif http_method == 'PUT':
        return update_item(item_id, body)
    elif http_method == 'DELETE':
        return delete_item(item_id)
    else:
        return generate_response(400, {'message': 'Invalid method'})
