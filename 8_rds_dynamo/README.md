# Dynamo DB

# DynamoDB Operations with AWS CLI and Terraform

This repository provides examples of managing DynamoDB using both AWS CLI and Terraform. It includes operations such as creating tables, adding indexes, inserting data, querying, and deleting items.

## Prerequisites

Before you begin, make sure you have the following installed:

- **AWS CLI**: For interacting with DynamoDB via the command line.
- **Terraform**: For provisioning and managing infrastructure as code.
- **AWS Account**: Ensure that your AWS CLI is configured with the necessary permissions to manage DynamoDB.

## Table of Contents

- [AWS CLI Operations](#aws-cli-operations)
    - [Create a Table](#create-a-table)
    - [Create an Index](#create-an-index)
    - [Insert Data](#insert-data)
    - [Query Data](#query-data)
    - [Delete Data](#delete-data)
    - [Delete a Table](#delete-a-table)
- [Terraform Operations](#terraform-operations)
    - [Create a Table](#create-a-table-terraform)
    - [Create an Index](#create-an-index-terraform)
    - [Insert Data](#insert-data-terraform)
    - [Delete a Table](#delete-a-table-terraform)
- [License](#license)

## AWS CLI Operations

### Create a Table

To create a DynamoDB table with a partition key `ID`:

```bash
aws dynamodb create-table \
    --table-name MyTable \
    --attribute-definitions AttributeName=ID,AttributeType=S \
    --key-schema AttributeName=ID,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5
```


### Create an Index
To create a Global Secondary Index (GSI) on the `GSIKey` attribute:
````bash
aws dynamodb update-table \
    --table-name MyTable \
    --attribute-definitions AttributeName=GSIKey,AttributeType=S \
    --global-secondary-indexes '[
        {
            "IndexName": "MyIndex",
            "KeySchema": [
                {"AttributeName": "GSIKey", "KeyType": "HASH"}
            ],
            "Projection": {"ProjectionType": "ALL"},
            "ProvisionedThroughput": {"ReadCapacityUnits": 5, "WriteCapacityUnits": 5}
        }
    ]'

````

### Insert Data
To insert a new item into the table:
````bash
aws dynamodb put-item \
    --table-name MyTable \
    --item '{"ID": {"S": "123"}, "Name": {"S": "John Doe"}, "Age": {"N": "30"}}'
````

### Query Data
To query data from the table based on the partition key `ID`:
````bash
aws dynamodb query \
    --table-name MyTable \
    --key-condition-expression "ID = :id" \
    --expression-attribute-values '{":id": {"S": "123"}}'

````

### Delete Data
To delete an item based on the partition key `ID`:
````bash
aws dynamodb delete-item \
    --table-name MyTable \
    --key '{"ID": {"S": "123"}}'
````

### Delete a Table
````bash
aws dynamodb delete-table --table-name MyTable
````


## Terraform Operations

### Create a Table (Terraform)
````hcl
resource "aws_dynamodb_table" "my_table" {
  name           = "MyTable"
  hash_key       = "ID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "ID"
    type = "S"
  }

  hash_key = "ID"
}
````

### Create an Index (Terraform)
````hcl
resource "aws_dynamodb_table" "my_table" {
  name           = "MyTable"
  hash_key       = "ID"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "ID"
    type = "S"
  }

  attribute {
    name = "GSIKey"
    type = "S"
  }

  global_secondary_index {
    name               = "MyIndex"
    hash_key           = "GSIKey"
    projection_type    = "ALL"
    read_capacity      = 5
    write_capacity     = 5
  }
}
````

### Insert Data (Terraform)
Although Terraform doesn’t directly insert data, you can use the `null_resource` with a `local-exec provisioner` to run AWS CLI commands for inserting data:
````hcl
resource "null_resource" "insert_item" {
  provisioner "local-exec" {
    command = "aws dynamodb put-item --table-name MyTable --item '{\"ID\": {\"S\": \"123\"}, \"Name\": {\"S\": \"John\"}}'"
  }
}
````

### Delete a Table (Terraform)
````hcl
resource "aws_dynamodb_table" "my_table" {
  name = "MyTable"
  lifecycle {
    prevent_destroy = false
  }
}
````
- Setting `prevent_destroy = false` allows the table to be deleted during `terraform destroy`.