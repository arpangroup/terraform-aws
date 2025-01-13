import json

def lambda_handler(event, context):
    print("Handling error...")

    # Log the error
    error_message = event.get("error", {}).get("Cause", "Unknown error")
    order_id = event.get("order_id", "Unknown order")

    print(f"Error occurred for order {order_id}: {error_message}")

    # Simulate notifying the support team
    print("Support team notified.")

    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Error handled successfully",
            "order_id": order_id,
            "error": error_message
        })
    }