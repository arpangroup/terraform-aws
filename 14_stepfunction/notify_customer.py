import json

def lambda_handler(event, context):
    print("Notifying customer...")

    # Simulate sending an email
    order_id = event.get("order_id")
    email = event.get("email")
    tracking_id = event.get("tracking_id")

    if not email:
        raise ValueError("Customer email is missing.")

    print(f"Notification sent to {email} for order {order_id}. Tracking ID: {tracking_id}")
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Customer notified successfully",
            "order_id": order_id,
            "email": email,
            "tracking_id": tracking_id
        })
    }