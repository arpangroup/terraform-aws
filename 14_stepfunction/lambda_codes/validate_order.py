import json


def lambda_handler(event, context):
    print("Validating order...")

    # Simulate order validation
    order_id = event.get("order_id")
    items = event.get("items", [])

    if not order_id or not items:
        raise ValueError("Invalid order: Missing order_id or items.")

    # Simulate stock check
    for item in items:
        if item.get("quantity", 0) <= 0:
            raise ValueError(f"Invalid quantity for item: {item.get('item_id')}")

    print(f"Order {order_id} is valid.")
    return {
        "statusCode": 200,
        "body": json.dumps({
            "message": "Order validated successfully",
            "order_id": order_id,
            "items": items
        })
    }
