import boto3
from botocore.exceptions import ClientError

REGION_NAME = 'us-east-1'
dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
table_name = "Users"

def create_table():
    print(f"Creating table: {table_name}")
    try:
        table = dynamodb.create_table(
            TableName=table_name,
            KeySchema=[
                {'AttributeName': 'user_id', 'KeyType': 'HASH'},  # Partition key
            ],
            AttributeDefinitions=[
                {'AttributeName': 'user_id', 'AttributeType': 'S'}, # S: String, N: Number, B: Binary
                # {'AttributeName': 'email', 'AttributeType': 'S'},  # Attribute for GSI
            ],
            # GlobalSecondaryIndexes=[
            #     {
            #         'IndexName': 'EmailIndex',
            #         'KeySchema': [
            #             {'AttributeName': 'email', 'KeyType': 'HASH'},  # GSI Partition Key
            #         ],
            #         'Projection': {'ProjectionType': 'ALL'},
            #         'ProvisionedThroughput': {'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
            #     },
            # ],
            ProvisionedThroughput={'ReadCapacityUnits': 5, 'WriteCapacityUnits': 5}
        )
        table.wait_until_exists()
        print(f"Table {table_name} created successfully.")
    except ClientError as e:
        print(f"Error creating table: {e.response['Error']['Message']}")
    return table

def insert_item(user_id, name, email):
    table = dynamodb.Table(table_name)
    print(f"Inserting item with user_id={user_id}, name={name}, email={email}")
    try:
        response = table.put_item(
            Item={
                'user_id': user_id,
                'name': name,
                'email': email,
            }
        )
        print("Insert successful:", response)
    except ClientError as e:
        print(f"Error inserting item: {e.response['Error']['Message']}")

def query_item(user_id):
    table = dynamodb.Table(table_name)
    print(f"Querying item with user_id={user_id}")
    try:
        response = table.get_item(Key={'user_id': user_id})

        # Query Using the GSI
        # response = table.query(
        #     IndexName='EmailIndex',
        #     KeyConditionExpression=Key('email').eq(email)
        # )

        # Using a Scan (Not Recommended for Large Tables)
        # response = table.scan(
        #     FilterExpression=Attr('email').eq('john@example.com')
        # )

        item = response.get('Item')
        if item:
            print("Item found:", item)
        else:
            print("Item not found.")
    except ClientError as e:
        print(f"Error querying item: {e.response['Error']['Message']}")

def query_item_with_conditions(email=None, name=None):
    table = dynamodb.Table('Users')
    print(f"Scanning table with conditions: email={email}, name={name}")

    # Build FilterExpression
    filter_expression = []
    if email:
        filter_expression.append(Attr('email').eq(email))
    if name:
        filter_expression.append(Attr('name').eq(name))


    # Combine conditions with AND
    combined_filter = None
    if filter_expression:
        combined_filter = filter_expression[0]
        for condition in filter_expression[1:]:
            combined_filter = combined_filter & condition


    try:
        if combined_filter:
            response = table.scan(
                FilterExpression=combined_filter
            )
        else:
            response = table.scan()

        items = response.get('Items', [])
        if items:
            print(f"Items found: {items}")
        else:
            print("No items found with the specified conditions.")
        return items
    except ClientError as e:
        print(f"Error scanning with conditions: {e.response['Error']['Message']}")


def update_item(user_id, name=None, email=None):
    table = dynamodb.Table(table_name)
    print(f"Updating item with user_id={user_id}, name={name}, email={email}")
    update_expression = []
    expression_values = {}
    expression_attribute_names = {}

    if name:
        update_expression.append("#nm = :name")
        expression_values[":name"] = name
        expression_attribute_names["#nm"] = "name"  # Placeholder for reserved keyword
    if email:
        update_expression.append("email = :email")
        expression_values[":email"] = email

    try:
        response = table.update_item(
            Key={'user_id': user_id},
            UpdateExpression="SET " + ", ".join(update_expression),
            ExpressionAttributeValues=expression_values,
            ExpressionAttributeNames=expression_attribute_names,
            ReturnValues="UPDATED_NEW"
        )
        print("Update successful:", response)
    except ClientError as e:
        print(f"Error updating item: {e.response['Error']['Message']}")

def delete_item(user_id):
    table = dynamodb.Table(table_name)
    print(f"Deleting item with user_id={user_id}")
    try:
        response = table.delete_item(Key={'user_id': user_id})
        print("Delete successful:", response)
    except ClientError as e:
        print(f"Error deleting item: {e.response['Error']['Message']}")

def delete_table():
    try:
        table = dynamodb.Table(table_name)
        response = table.delete()
        print(f"Deleting table {table_name}...")
        table.wait_until_not_exists()
        print(f"Table {table_name} deleted successfully.")
        return response
    except ClientError as e:
        print(f"Error deleting table {table_name}: {e.response['Error']['Message']}")

# Example usage
if __name__ == '__main__':
    print("Starting example usage...")
    # create_table()
    # insert_item("1", "John Doe", "john@example.com")
    # query_item("1")
    # update_item("1", name="John Updated")
    # delete_item("1")
    delete_table()
    # print("Example usage completed.")
