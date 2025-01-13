import json
import uuid

def lambda_handler(event, context):
    print("Preparing shipment...")

    # Simulate shipment preparation
    order_id = event.get("order_id")
    shipping_address = event.get("shipping_address")

    if not shipping_address:
        raise ValueError("Shipping address is missing.")

    # Generate a fake tracking ID
    tracking_id = str(uuid.uuid4())

    print(f"Shipment prepared for order {order_id}. Tracking ID: {tracking_id}")
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Shipment prepared successfully",
            "order_id": order_id,
            "tracking_id": tracking_id,
            "shipping_address": shipping_address
        })
    }