import json

def lambda_handler(event, context):
    print("Processing payment...")

    # Simulate payment processing
    order_id = event.get("order_id")
    amount = event.get("amount", 0)

    if amount <= 0:
        raise ValueError("Invalid payment amount.")

    print(f"Payment processed for order {order_id}. Amount: ${amount}")
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Payment processed successfully",
            "order_id": order_id,
            "amount": amount
        })
    }