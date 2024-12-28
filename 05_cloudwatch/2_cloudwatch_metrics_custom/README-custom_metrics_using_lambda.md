# CloudWatch Custom Metrics Using Lambda

## Step1: Set Up AWS Lambda Environment
Navigate to Lambda and create a new function.
- Choose Author from scratch.
- Provide a function name.
- Select Python or Node.js runtime (or your preferred language).


## Step2: Add IAM Role Permissions
Ensure the Lambda function has an execution role with the `CloudWatchFullAccess` or equivalent custom policy that allows `cloudwatch:PutMetricData`.

## Step3: Implement the Lambda Function
````python
import boto3
import time
from datetime import datetime

# Create a CloudWatch client
cloudwatch = boto3.client('cloudwatch')

def lambda_handler(event, context):
    # Custom metric details
    namespace = 'MyCustomApp'
    metric_name = 'CheckoutFailures'
    metric_value = event.get('failureCount', 1)  # Pass the value via event payload
    timestamp = datetime.utcnow()
    
    # Send the metric to CloudWatch
    response = cloudwatch.put_metric_data(
        Namespace=namespace,
        MetricData=[
            {
                'MetricName': metric_name,
                'Timestamp': timestamp,
                'Value': metric_value,
                'Unit': 'Count',
            },
        ]
    )
    return {
        'statusCode': 200,
        'body': f'Metric {metric_name} with value {metric_value} sent successfully!'
    }

````

## Step4: Deploy and Test the Function
- Deploy the Lambda function.
- Test the function:
  - Use the **Test** tab in the Lambda Console
  - Provide a test event JSON payload, e.g., `{ "failureCount": 5 }`.

## Step5: Verify the Custom Metric in AWS CloudWatch
1. Open the CloudWatch Console.
2. Go to **Metrics > All Metrics > Custom Namespaces**.
3. Select the `MyCustomApp` namespace to view your `CheckoutFailures` metric.

## Optional: Automate Metric Collection
If you need periodic metrics, trigger the Lambda function using:
- **EventBridge (CloudWatch Events)**: Schedule the Lambda function to run at fixed intervals.
- **Triggers from Other Services**: For real-time data, trigger the Lambda function via S3, DynamoDB Streams, or any other AWS service.